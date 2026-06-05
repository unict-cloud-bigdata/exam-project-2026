-- Q1 — On-time performance by airline (carrier reliability ranking)
-- `flights` only has carrier code and calls it "AIRLINE", while `airlines` calls 
--    it "IATA_CODE", hence the join

-- INTENT: Rank carriers by percentage of delayed arrivals (ARRIVAL_DELAY >= 15 min, DOT threshold).
-- "Delayed" = ARRIVAL_DELAY >= 15 (official DOT threshold). 
-- Alternative to ranking by percentage delayed: rank by average arrival delay, 
--   but that can be skewed by a few extreme outliers
-- Cancelled flights (CANCELLED <> 0) excluded (WHERE...) - their delays are NULL. 
-- SAFE_DIVIDE guards against division by zero.

-- EXPECTED OUTCOME: a clear spread in % delayed across the ~14 carriers; low-cost carriers worse,
--   niche/legacy carriers better.
-- WHY: carriers differ in scheduling slack, hub-congestion exposure and fleet utilisation.
-- VALIDATED: yes, on the full table: 14 carriers; worst Spirit 30.5% and
--   Frontier 27.3%; best Hawaiian 11.5%, Alaska 13.2%, Delta 14.1%. Most carriers show
--   avg_dep_delay > avg_arr_delay (time recovered in the air; see Q6).

-- New BigQuery "pipeline" |> syntax, powerful and clear

SELECT
  a.IATA_CODE AS airline_code,
  a.AIRLINE AS airline_name,
  ROUND(AVG(f.DEPARTURE_DELAY), 1)  AS avg_dep_delay_min,
  ROUND(AVG(f.ARRIVAL_DELAY),  1)   AS avg_arr_delay_min,
  COUNT(*) AS flights_no,
  COUNTIF(f.ARRIVAL_DELAY >= 15) AS delayed_no,
  COUNTIF(f.ARRIVAL_DELAY IS NOT NULL) AS delay_non_null_no,
  COUNTIF(f.ARRIVAL_DELAY IS NULL) AS delay_null_no,
FROM flights_2015.flights AS f
JOIN flights_2015.airlines AS a ON f.AIRLINE = a.IATA_CODE
WHERE f.CANCELLED = 0
GROUP BY a.IATA_CODE, a.AIRLINE
|> EXTEND ROUND(100*(delayed_no / delay_non_null_no),1) AS pct_delayed
|> DROP delayed_no, delay_non_null_no, delay_null_no, flights_no
|> ORDER BY pct_delayed DESC;

-- Alternative standard SQL version without pipeline syntax, for comparison.
-- WILL NOT RUN! — standard-SQL equivalent (no pipeline syntax), kept inert as a block comment.
/*
SELECT
  a.IATA_CODE AS airline_code,
  a.AIRLINE AS airline_name,
  ROUND(AVG(f.DEPARTURE_DELAY), 1)  AS avg_dep_delay_min,
  ROUND(AVG(f.ARRIVAL_DELAY),  1)   AS avg_arr_delay_min,
  COUNT(*)                          AS flights_no,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(f.ARRIVAL_DELAY >= 15),
                          COUNTIF(f.ARRIVAL_DELAY IS NOT NULL)), 1) AS pct_delayed
FROM flights_2015.flights AS f
JOIN flights_2015.airlines AS a ON f.AIRLINE = a.IATA_CODE
WHERE f.CANCELLED = 0
GROUP BY airline_code, airline_name
ORDER BY pct_delayed DESC;
*/

