"""
Data Transformer - project runner
---------------------------------
1. Builds an SQLite database from sql/01_schema.sql and sql/02_sample_data.sql
2. Executes every query in sql/03_queries.sql
3. Writes the results to output/query_results.pdf

Usage:  python run_project.py
Needs:  Python 3.8+, SQLite 3.39+ (bundled with Python), reportlab (pip install reportlab)
"""
import re
import sqlite3
from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (KeepTogether, PageBreak, Paragraph, Preformatted,
                                SimpleDocTemplate, Spacer, Table, TableStyle)

ROOT = Path(__file__).parent
SQL_DIR, OUT_DIR = ROOT / "sql", ROOT / "output"
OUT_DIR.mkdir(exist_ok=True)


def build_database():
    con = sqlite3.connect(":memory:")
    con.executescript((SQL_DIR / "01_schema.sql").read_text())
    con.executescript((SQL_DIR / "02_sample_data.sql").read_text())
    return con


def parse_queries():
    text = (SQL_DIR / "03_queries.sql").read_text()
    pattern = re.compile(r"^-- @Q(\d+) \| (.+?) \| (.+)$", re.M)
    matches = list(pattern.finditer(text))
    queries = []
    for i, m in enumerate(matches):
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        queries.append({"n": int(m.group(1)), "topic": m.group(2).strip(),
                        "task": m.group(3).strip(), "sql": text[m.end():end].strip()})
    return queries


def fmt(v):
    if v is None:
        return "NULL"
    if isinstance(v, float):
        return f"{v:,.2f}"
    return str(v)


def run_all():
    con = build_database()
    results = []
    for q in parse_queries():
        cur = con.execute(q["sql"])
        q["cols"] = [d[0] for d in cur.description]
        q["rows"] = cur.fetchall()
        results.append(q)
    con.close()
    return results


def make_table(cols, rows, avail_width, cell, head):
    data = [[Paragraph(c, head) for c in cols]]
    for r in rows:
        data.append([Paragraph(fmt(v).replace("&", "&amp;").replace("<", "&lt;"), cell) for v in r])
    lens = [max([len(c)] + [len(fmt(r[i])) for r in rows]) + 2 for i, c in enumerate(cols)]
    total = sum(lens)
    widths = [avail_width * l / total for l in lens]
    t = Table(data, colWidths=widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1F3A5F")),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#B8C2CC")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F2F5F8")]),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 3), ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
    ]))
    return t


def build_pdf(results):
    pdf_path = OUT_DIR / "query_results.pdf"
    page = landscape(A4)
    doc = SimpleDocTemplate(str(pdf_path), pagesize=page, leftMargin=15 * mm, rightMargin=15 * mm,
                            topMargin=14 * mm, bottomMargin=14 * mm,
                            title="Data Transformer - SQL Project Output", author="Data Transformer Project")
    avail = page[0] - 30 * mm
    ss = getSampleStyleSheet()
    title = ParagraphStyle("t", parent=ss["Title"], fontSize=26, textColor=colors.HexColor("#1F3A5F"))
    h1 = ParagraphStyle("h1", parent=ss["Heading1"], fontSize=15, textColor=colors.HexColor("#1F3A5F"), spaceAfter=2)
    h2 = ParagraphStyle("h2", parent=ss["Heading2"], fontSize=12, textColor=colors.HexColor("#1F3A5F"))
    body = ParagraphStyle("b", parent=ss["BodyText"], fontSize=10, leading=14)
    small = ParagraphStyle("s", parent=body, fontSize=9, textColor=colors.HexColor("#444444"))
    cell = ParagraphStyle("c", parent=body, fontSize=8, leading=10)
    head = ParagraphStyle("hd", parent=cell, textColor=colors.white, fontName="Helvetica-Bold")
    code = ParagraphStyle("code", fontName="Courier", fontSize=7.5, leading=9.5,
                          backColor=colors.HexColor("#F4F4F4"), borderPadding=4, leftIndent=4)

    s = [Spacer(1, 8 * mm), Paragraph("Data Transformer", title),
         Paragraph("Advanced SQL Project &ndash; Query Results", ParagraphStyle("st", parent=body, fontSize=14, alignment=1)),
         Spacer(1, 8 * mm),
         Paragraph(f"Generated on {date.today():%d-%b-%Y} &nbsp;|&nbsp; Engine: SQLite {sqlite3.sqlite_version} "
                   f"&nbsp;|&nbsp; Queries executed: {len(results)}", ParagraphStyle("m", parent=small, alignment=1)),
         Spacer(1, 6 * mm),
         Paragraph("Contents", h1)]
    for q in results:
        s.append(Paragraph(f"Q{q['n']}. {q['topic']} &ndash; <font color='#666666'>{q['task']}</font>", small))
    s.append(PageBreak())

    # Table overview page: show base data so results can be verified
    con = build_database()
    s.append(Paragraph("Source Data (Sample Tables)", h1))
    for name in ("Customers", "Orders", "Employees"):
        cur = con.execute(f"SELECT * FROM {name}")
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        s.append(Paragraph(f"{name} ({len(rows)} rows)", h2))
        s.append(make_table(cols, rows, avail, cell, head))
        s.append(Spacer(1, 3 * mm))
        if name == "Orders":
            s.append(PageBreak())
    con.close()
    s.append(PageBreak())

    for q in results:
        block = [Paragraph(f"Query {q['n']}: {q['topic']}", h1),
                 Paragraph(f"<b>Task:</b> {q['task']}", body), Spacer(1, 2 * mm),
                 Preformatted(q["sql"], code), Spacer(1, 3 * mm),
                 Paragraph(f"Result &ndash; {len(q['rows'])} row(s)", h2)]
        tbl = make_table(q["cols"], q["rows"], avail, cell, head) if q["rows"] else Paragraph("(no rows)", body)
        s.append(KeepTogether(block + [tbl]) if len(q["rows"]) <= 12 else block[0])
        if len(q["rows"]) > 12:
            s.extend(block[1:] + [tbl])
        s.append(PageBreak())
    s.pop()
    doc.build(s, onFirstPage=footer, onLaterPages=footer)
    return pdf_path


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.grey)
    canvas.drawString(15 * mm, 8 * mm, "Data Transformer - SQL Project")
    canvas.drawRightString(landscape(A4)[0] - 15 * mm, 8 * mm, f"Page {doc.page}")
    canvas.restoreState()


if __name__ == "__main__":
    res = run_all()
    for q in res:
        print(f"Q{q['n']:>2} {q['topic']:<24} -> {len(q['rows'])} row(s)")
    print("PDF written to:", build_pdf(res))
