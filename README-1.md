# Chinook Digital Music Store — Advanced SQL Business Analysis

## Overview
An advanced SQL analysis project on **Chinook**, a real relational database modeling a digital music store (think iTunes-style business): customers, invoices, tracks, albums, artists, genres, employees, and playlists across **11 interconnected tables**.

This project answers 12 real business questions using advanced SQL techniques — not just basic `SELECT` statements.

## Database Schema
11 tables, ~3,500 tracks, 412 invoices, 59 customers, 8 employees:

```
Artist ──< Album ──< Track >── Genre
                       │
                       ├──< PlaylistTrack >── Playlist
                       │
                       └──< InvoiceLine >── Invoice >── Customer >── Employee
                                                                      (SupportRep)
```
(`──<` = one-to-many relationship)

## SQL Techniques Demonstrated
- Multi-table JOINs (up to 5 tables deep)
- Common Table Expressions (CTEs), including chained/nested CTEs
- Window functions: `RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, running totals with `SUM() OVER()`
- Correlated & nested subqueries
- `CASE WHEN` segmentation logic
- Date functions (`strftime`) for time-series analysis
- Percentage-of-total calculations with `PARTITION BY`

## Business Questions Answered
| # | Question | Technique |
|---|---|---|
| Q1 | Top 10 countries by revenue | JOIN + aggregate |
| Q2 | Top 10 customers by lifetime value | RANK() window function |
| Q3 | Monthly revenue trend + running total | CTE + running SUM window |
| Q4 | Best-selling genres | 4-table JOIN |
| Q5 | Top artists by revenue | 5-table JOIN chain |
| Q6 | Employee/sales rep performance | 3-table JOIN |
| Q7 | Customer value segmentation | NTILE() window function |
| Q8 | Best-selling track per genre | ROW_NUMBER() PARTITION BY |
| Q9 | Above-average spending customers | Correlated subquery |
| Q10 | Album vs single-track purchase behavior | Nested CTEs |
| Q11 | Year-over-year revenue growth | LAG() + % growth calc |
| Q12 | Playlist genre composition | 4-table JOIN + % of total |

## Key Findings (see `business_insights.md` for full detail)
- Rock is the dominant genre by revenue (~2x the next genre)
- USA, Canada, and France are the top 3 markets
- Customers overwhelmingly buy single tracks over full albums (~4% album completion rate)
- Revenue has been flat year-over-year, pointing to an acquisition (not retention) problem

## Files
- `chinook.db` — the SQLite database (source: [lerocha/chinook-database](https://github.com/lerocha/chinook-database), a widely-used open sample database)
- `advanced_queries.sql` — all 12 queries, commented with business context
- `Chinook_SQL_Analysis_Results.xlsx` — every query's output, one sheet per query + an index sheet
- `business_insights.md` — plain-English summary of findings and recommendations

## How to Run
```bash
sqlite3 chinook.db < advanced_queries.sql
```
Or open `chinook.db` in any SQL client (DB Browser for SQLite, DBeaver, etc.) and run queries individually.

---
*Built as a freelance portfolio project — Advanced SQL / Business Analysis.*
