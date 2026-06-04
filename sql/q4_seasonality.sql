-- Q4 — Seasonality: average delay and cancellation rate by month
-- Months 1-9, 11, 12 (October removed at the source, before upload).
-- Cancellation rate over ALL flights; average arrival delay over non-cancelled
-- (cancelled flights have NULL delays, which AVG ignores).
--
-- EXPECTED: more cancellations in winter (snow/ice), higher delays in summer.
-- WHY: winter storms drive cancellations; summer convective weather and peak demand drive
--   en-route/airport delays.
-- VALIDATED: yes, on the full table (2026-06-03). Cancellations peak Feb 4.78%, Jan 2.55%;
--   arrival delay peaks Jun 9.6 min; September calmest (-0.8 min, 0.45% cancelled).

SELECT
  MONTH                          AS month,
  COUNT(*)                       AS total_flights,
  ROUND(AVG(ARRIVAL_DELAY), 1)   AS avg_arr_delay_min,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(CANCELLED = 1), COUNT(*)), 2) AS cancellation_rate_pct
FROM flights_2015.flights
GROUP BY month
ORDER BY month;
