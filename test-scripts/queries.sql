-- ============================================================================
-- TEST-SKRIPT FOR OBLIG 1
-- ============================================================================

-- Kjør med: docker-compose exec postgres psql -h -U admin -d data1500_db -f test-scripts/queries.sql

-- En test med en SQL-spørring mot metadata i PostgreSQL (kan slettes fra din script)
select nspname as schema_name from pg_catalog.pg_namespace;

select * from bikes;

select last_name as etternavn
     ,first_name as fornavn
     ,phone_number as telefonnummer
from customers
order by last_name; -- asc er default

select * from bikes
where bike_added_date > '2025-02-25 08:00';

select count(*) from customers;

select c.first_name
     , c.last_name
     , count(r.rental_id) as utleietilfeller
from customers c
         left join rentals r on c.customer_id = r.customer_id
group by c.first_name, c.last_name;

select c.first_name
     , c.last_name
     , count(r.rental_id) as utleietilfeller
from customers c
         left join rentals r on c.customer_id = r.customer_id
group by c.first_name, c.last_name
having count(r.rental_id) = 0 OR count(r.rental_id) IS NULL;

select bike_model
     , b.bike_id
     , count(r.rental_id) as utleietilfeller
from bikes b
         left join rentals r on b.bike_id = r.bike_id
GROUP BY bike_model, b.bike_id
having count(r.rental_id) = 0 or count(r.rental_id) IS NULL;

select rs.station_id
     , b.bike_model
     , b.bike_id
     , c.first_name
     , c.last_name
     , r.start_time
from rentals r
         join bikes b on r.bike_id = b.bike_id
         join customers c on r.customer_id = c.customer_id
         join rental_stations rs on r.start_station_id = rs.station_id
where end_time IS NULL AND start_time < (NOW() - INTERVAL '24 hours');

