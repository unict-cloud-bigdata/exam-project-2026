-- Q5 — Decomposition of delay causes (delayed flights only)
-- The five cause columns are NULL unless a flight is delayed; IFNULL -> 0.
-- Each share = % of total attributed delay minutes across all five causes.
-- Per-airline variant: add `f.AIRLINE` to the CTE GROUP BY and join airlines (done in the notebook).
--
-- EXPECTED: late_aircraft (knock-on propagation) is the largest single cause; security ~0.
-- WHY: once aircraft/crews fall behind, delay cascades to later flights, structurally
--   outweighing weather- or carrier-specific causes.
-- VALIDATED: yes, on the full table (2026-06-03). late_aircraft 40.1%, airline 32.0%,
--   air_system 22.8%, weather 5.0%, security 0.1%. Direct weather is small because weather
--   also hides inside the air_system and late_aircraft buckets.

WITH delayed AS (
  SELECT
    SUM(IFNULL(AIR_SYSTEM_DELAY,    0)) AS air_system,
    SUM(IFNULL(SECURITY_DELAY,      0)) AS security,
    SUM(IFNULL(AIRLINE_DELAY,       0)) AS airline,
    SUM(IFNULL(LATE_AIRCRAFT_DELAY, 0)) AS late_aircraft,
    SUM(IFNULL(WEATHER_DELAY,       0)) AS weather
  FROM flights_2015.flights
  WHERE CANCELLED = 0 AND ARRIVAL_DELAY >= 15
)
SELECT
  ROUND(100 * air_system    / (air_system + security + airline + late_aircraft + weather), 1) AS pct_air_system,
  ROUND(100 * security      / (air_system + security + airline + late_aircraft + weather), 1) AS pct_security,
  ROUND(100 * airline       / (air_system + security + airline + late_aircraft + weather), 1) AS pct_airline,
  ROUND(100 * late_aircraft / (air_system + security + airline + late_aircraft + weather), 1) AS pct_late_aircraft,
  ROUND(100 * weather       / (air_system + security + airline + late_aircraft + weather), 1) AS pct_weather
FROM delayed;
