# Business Insights — Chinook Digital Music Store

Summary of key findings from the SQL analysis. Full query results are in `Chinook_SQL_Analysis_Results.xlsx`.

## 1. Revenue Concentration by Geography
The **USA (~$523)**, **Canada (~$304)**, and **France (~$195)** are the top 3 revenue markets. Marketing and localization budget should prioritize these regions before expanding into lower-revenue countries.

## 2. Genre Strategy
**Rock (~$827)** dominates genre revenue — more than double the next genre (Latin, ~$382). Any promotional playlist, homepage feature, or new-artist-acquisition budget should weight heavily toward Rock inventory.

## 3. Purchase Behavior: Singles vs Albums
Only **49 full-album purchases** vs **1,252 partial/single-track purchases** — customers overwhelmingly buy individual tracks rather than full albums (~4% album completion rate). This validates a pay-per-track pricing model over bundled album pricing, and suggests album-exclusive tracks may hurt conversion.

## 4. Revenue Trend
Yearly revenue has been relatively flat (~$450–480K/year range) with no strong growth trend — worth investigating whether customer acquisition has stalled, since repeat purchase volume per customer is consistent year over year.

## 5. Customer Value Tiers
Customers split into High / Mid / Low value tiers (NTILE segmentation) show the **top third of customers contribute ~33% more revenue on average** than the bottom third — a loyalty or win-back campaign targeted at the mid/low tiers has clear upside.

## 6. Support Rep Performance
Only 3 employees handle all customer accounts — revenue-per-rep analysis (see Q6) can inform staffing and commission decisions.

## Recommendations
1. Prioritize Rock-genre content acquisition and marketing
2. Shift promotional focus toward USA/Canada/France
3. Reconsider album-bundle pricing — customers prefer singles
4. Launch a loyalty campaign targeting Mid/Low value tiers to lift average spend
5. Investigate flat YoY revenue — likely a customer acquisition (not retention) problem, since repeat spend per customer is stable
