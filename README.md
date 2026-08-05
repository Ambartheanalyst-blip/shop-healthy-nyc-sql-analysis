# Shop Healthy NYC: A Flat Citywide Number Hides Very Different Borough Trends

**Ambar Pierret** · SQL / PostgreSQL analysis of NYC Open Data

## Summary

Between 2013 and 2024, NYC's Shop Healthy NYC program recognized 709 bodegas and grocery stores for stocking and promoting healthier food — all within the Bronx, Brooklyn, and Manhattan neighborhoods it targets. Citywide, recognitions look roughly flat over the decade (-6.8%). Breaking the numbers out by borough tells a different story: Brooklyn's participation grew 13.3% over that same span, while the Bronx fell 11.0% and Manhattan fell 25.0% — the steepest decline.

## The Question

Within the three boroughs the Shop Healthy Retail Challenge actually serves, which zip codes and community boards received the most recognitions between 2013 and 2024, and has participation grown, stalled, or declined over time — does that pattern look the same across boroughs?

I care about this because my family and I live in the Bronx, where healthy food options are limited and bodegas are often the primary food source in neighborhoods without full-service supermarkets. Shop Healthy NYC targets areas around the Health Department's three Neighborhood Health Action Centers — East Harlem, Tremont in the Bronx, and Brownsville in Brooklyn — so whether recognitions grow or fade there says something real about the program's reach.

## Data & Method

**Source:** [Recognized Shop Healthy Stores](https://data.cityofnewyork.us/Health/Recognized-Shop-Healthy-Stores/ud4g-9x9z), NYC Department of Health and Mental Hygiene, via NYC Open Data (2025). 709 rows, downloaded via the Open Data API and imported into PostgreSQL as `shop_healthy_stores`; verified with row-count, date-range, and sample checks (709 rows, 2013–2024, no rows for 2021).

**Cleaning:** The borough column used two labels for one borough ("New York" and "Manhattan") — fixed via `UPDATE`. `BIN`, `BBL`, latitude, and longitude were dropped before import (Excel's comma-formatting kept corrupting those columns on export, and none of the four feed any query here). Community board is missing on a small number of rows, so the analysis relies on the complete fields: borough, zip code, year.

**Lookup table:** A second table, `community_board_lookup`, maps community board codes to real neighborhood names (sourced from NYC's Community Boards office) and joins on `community_board` for Table 4 below.

Full queries — filtering, aggregate, grouping, percent-change, ranking, and join — are in [`Healthy_Stores_NYC_Final_Project.sql`](./Healthy_Stores_NYC_Final_Project.sql).

## Findings

**Table 1 — Recognitions by borough (2013–2024)**

| Borough | Total Recognitions |
|---|---|
| Bronx | 312 |
| Brooklyn | 245 |
| Manhattan | 152 |

The Bronx received the most recognitions overall, followed by Brooklyn and Manhattan.

**Table 2 — Citywide recognitions by year**

| Year | Recognitions |
|---|---|
| 2013 | 44 |
| 2014 | 27 |
| 2015 | 60 |
| 2016 | 44 |
| 2017 | 119 |
| 2018 | 73 |
| 2019 | 68 |
| 2020 | 116 |
| 2021 | 0 |
| 2022 | 32 |
| 2023 | 92 |
| 2024 | 34 |

Recognitions arrive in distinct waves (2017, 2020, 2023) rather than a smooth trend, including a complete gap in 2021.

**Table 2B — Change by borough, early vs. recent period (the central finding)**

| Borough | 2013–2017 | 2020–2024 | % Change |
|---|---|---|---|
| Brooklyn | 90 | 102 | +13.3% |
| Bronx | 136 | 121 | −11.0% |
| Manhattan | 68 | 51 | −25.0% |

The citywide -6.8% conceals sharply different local patterns: Brooklyn actually grew between its earliest and most recent five-year windows, while the Bronx and especially Manhattan declined.

**Table 3 — Top 10 zip codes by recognitions**

| Rank | Zip Code | Borough | Recognitions | % of Citywide |
|---|---|---|---|---|
| 1 | 10453 | Bronx | 65 | 9.2% |
| 2 | 11221 | Brooklyn | 57 | 8.0% |
| 3 | 10029 | Manhattan | 56 | 7.9% |

**Table 4 — Top neighborhoods (via join to `community_board_lookup`)**

| Neighborhood | Borough | Recognitions |
|---|---|---|
| Fordham, University Heights, Mount Hope | Bronx | 84 |
| East Harlem | Manhattan | 80 |

Fordham/University Heights (Bronx) and East Harlem (Manhattan) are the two strongest individual neighborhoods — but both sit in boroughs whose overall trend is now declining, meaning strong past participation isn't translating into continued growth.

## So What

Shop Healthy NYC's roughly flat citywide number masks a real divergence: Brooklyn is growing while the Bronx and especially Manhattan are falling behind, even in neighborhoods with the strongest track record. The NYC Department of Health and the Manhattan and Bronx Borough Presidents' offices would benefit from examining what changed in Brooklyn's most recent program waves and applying those lessons to East Harlem and the Bronx's Action Center areas. Future analysis should also test whether wave scheduling itself, rather than genuine decline, explains part of this pattern.

## Tools & Acknowledgment

PostgreSQL · Claude (query troubleshooting and framing) · NYC Open Data
