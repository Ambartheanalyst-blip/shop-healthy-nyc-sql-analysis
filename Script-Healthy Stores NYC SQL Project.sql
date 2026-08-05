-- Creating table 
CREATE TABLE shop_healthy_stores (
    store_name        TEXT,
    street_address    TEXT,
    borough           TEXT,
    zip_code          TEXT,
    year_awarded      INTEGER,
    program_wave      INTEGER,
    community_board   TEXT
);

-- Confirming the data importing worked
SELECT COUNT(*) AS total_rows 
FROM shop_healthy_stores;

SELECT MIN(year_awarded) AS earliest_year, 
MAX(year_awarded) AS latest_year
FROM shop_healthy_stores_raw;    

SELECT * 
FROM shop_healthy_stores 
LIMIT 10;

SELECT 
COUNT(*) FILTER (WHERE store_name IS NULL) AS null_store_name,
COUNT(*) FILTER (WHERE borough IS NULL) AS null_borough,
COUNT(*) FILTER (WHERE community_board IS NULL) AS null_community_board
FROM shop_healthy_stores;  --There is only 74 null community board values

-- I had to clean the borough column because "New York" and "Manhattan" are present as two different borughs when it should not.
SELECT borough, COUNT(*) 
FROM shop_healthy_stores 
GROUP BY borough ORDER BY borough DESC;   -- see the problem

--Fixing the mislabeling after confirming the addresses for both labels are in Manhattan
UPDATE shop_healthy_stores
SET borough = 'Manhattan' WHERE borough = 'New York';

--Confiming if the update worked
SELECT borough,
COUNT(*) FROM shop_healthy_stores 
GROUP BY borough 
ORDER BY borough DESC; -- It did work, now Manhattan has 152 entries.

-- Building a second table: Community_board_lookup table translate the community_board codes into real neighborhood names, I used the NYC'S Community Boards office pages to confirm translation

CREATE TABLE community_board_lookup (
			community_board TEXT PRIMARY KEY,
			borough TEXT NOT NULL,
			district_number INT NOT NULL,
			neighborhood_name TEXT NOT NULL);
			
-- Now I have to insert the data inside the table 	
 INSERT INTO community_board_lookup (community_board, borough, district_number, neighborhood_name) 
 VALUES
    ('109','Manhattan', 9, 'Morningside Heights, Manhattanville, Hamilton Heights, Sugar Hill, West Harlem'),
    ('110','Manhattan',10, 'Central Harlem'),
    ('111','Manhattan',11, 'East Harlem'),
    ('201','Bronx',     1, 'Mott Haven, Port Morris, Melrose'),
    ('202','Bronx',     2, 'Hunts Point, Longwood, Morrisania'),
    ('203','Bronx',     3, 'Crotona Park, Claremont Village, Concourse Village, Morrisania'),
    ('204','Bronx',     4, 'Highbridge, Concourse, Mount Eden, Concourse Village'),
    ('205','Bronx',     5, 'Fordham, University Heights, Morris Heights, Bathgate, Mount Hope'),
    ('206','Bronx',     6, 'Belmont, Bathgate, West Farms, East Tremont, Bronx Park South'),
    ('207','Bronx',     7, 'Norwood, University Heights, Jerome Park, Bedford Park, Kingsbridge Heights'),
    ('301','Brooklyn',  1, 'Greenpoint, Williamsburg'),
    ('303','Brooklyn',  3, 'Bedford-Stuyvesant, Stuyvesant Heights'),
    ('304','Brooklyn',  4, 'Bushwick'),
    ('305','Brooklyn',  5, 'East New York, Cypress Hills, Highland Park, New Lots, City Line, Starrett City'),
    ('308','Brooklyn',  8, 'Crown Heights, Prospect Heights, Weeksville'),
    ('316','Brooklyn', 16, 'Brownsville, Ocean Hill'),
    ('317','Brooklyn', 17, 'East Flatbush, Remsen Village, Farragut, Rugby, Erasmus, Ditmas Village');
-- Researched the name on the official website and got help from CLAUDE AI to organize it all by code

--Now I will confirm the table has a match to the main table by using JOIN 
SELECT DISTINCT s.community_board
FROM shop_healthy_stores s
LEFT JOIN community_board_lookup cb
ON s.community_board = cb.community_board; --Confirmed with 18 rows, inlcuding Null value

-- PART 3 OF THE PROJECT 	

-- Query 1: WHERE + IN + ORDER BY + LIMIT. This shows the top stores behind the top zip codes
SELECT store_name, zip_code, borough, year_awarded
FROM shop_healthy_stores
WHERE zip_code IN ('10453', '11221', '10029')
ORDER BY zip_code, year_awarded DESC
LIMIT 15;
 
-- Query 2: shape of the data (COUNT/MIN/MAX)
SELECT COUNT(*) AS total_recognitions, 
MIN(year_awarded) AS earliest_year, 
MAX(year_awarded) AS latest_year
FROM shop_healthy_stores;

-- Query 3 -- which borough gets the most recognitions?
-- GROUP BY + HAVING (>100) to focus on the boroughs that matter at scale.
-- -> REPORT TABLE 1
SELECT borough, COUNT(*) AS total_recognitions
FROM shop_healthy_stores
GROUP BY borough
HAVING COUNT(*) > 100
ORDER BY total_recognitions DESC;

-- Query 4 -- is this "growing or shrinking" at the simplest level?
-- -> REPORT TABLE 2
SELECT year_awarded, 
COUNT(*) AS total_recognitions
FROM shop_healthy_stores
GROUP BY year_awarded
ORDER BY year_awarded;

-- Query 5a --Interpreting Query 4 with before/after number using CASE + percent-change math.
SELECT
    SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END) AS early_period_2013_2017,
    SUM(CASE WHEN year_awarded BETWEEN 2020 AND 2024 THEN 1 ELSE 0 END) AS recent_period_2020_2024,
    ROUND(100.0 * (
        SUM(CASE WHEN year_awarded BETWEEN 2020 AND 2024 THEN 1 ELSE 0 END)
      - SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END)
    ) / SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END), 1) AS percent_change
FROM shop_healthy_stores;

-- Query 5b -- I did GROUP BY borough to dive deeper into the specific changes by borough over early and late years
-- -> REPORT TABLE 2B
SELECT
    borough,
    SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END) AS early_period_2013_2017,
    SUM(CASE WHEN year_awarded BETWEEN 2020 AND 2024 THEN 1 ELSE 0 END) AS recent_period_2020_2024,
    ROUND(100.0 * (
        SUM(CASE WHEN year_awarded BETWEEN 2020 AND 2024 THEN 1 ELSE 0 END)
      - SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END)
    ) / SUM(CASE WHEN year_awarded BETWEEN 2013 AND 2017 THEN 1 ELSE 0 END), 1) AS percent_change
FROM shop_healthy_stores
GROUP BY borough
ORDER BY percent_change DESC;

-- Query 6 --  Table 1 answers it by borough; this answers by at zip code, using a subquery so the "% of total" always recalculates correctly even if the data changes.
-- -> REPORT TABLE 3
SELECT
    zip_code,
    COUNT(*) AS total_recognitions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shop_healthy_stores), 1) AS pct_of_all_recognitions
FROM shop_healthy_stores
GROUP BY zip_code
ORDER BY total_recognitions DESC
LIMIT 10;

-- Query 7 -- Used JOIN to the lookup table to re-run the ranking with real neighborhood names instead of codes.
-- -> REPORT TABLE 4
SELECT
    l.neighborhood_name,
    l.borough,
    COUNT(*) AS total_recognitions
FROM shop_healthy_stores s
JOIN community_board_lookup l ON s.community_board = l.community_board
GROUP BY l.neighborhood_name, l.borough
ORDER BY total_recognitions DESC;



