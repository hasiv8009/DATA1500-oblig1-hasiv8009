-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================
--Rydd opp gammelt rot:
DROP TABLE IF EXISTS rentals CASCADE;
DROP TABLE IF EXISTS bikes CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS rental_stations CASCADE;



-- Opprett grunnleggende tabeller

-- Utleiestasjoner:
CREATE TABLE rental_stations (
                                 station_id       SERIAL PRIMARY KEY,
                                 station_name     VARCHAR(20) NOT NULL,
                                 station_address  VARCHAR(50) NOT NULL,

                                 CONSTRAINT station_name_not_blank
                                     CHECK (length(trim(station_name)) > 0),
                                 CONSTRAINT station_address_not_blank
                                     CHECK (length(trim(station_address)) > 0)
);

-- 2) Sykler:
CREATE TABLE bikes (
                       bike_id          SERIAL PRIMARY KEY,
                       bike_model       VARCHAR(20) NOT NULL,
                       current_status   VARCHAR(20) NOT NULL,
                       station_id       INTEGER NULL REFERENCES rental_stations(station_id),
                       bike_added_date  TIMESTAMPTZ NOT NULL DEFAULT now(),

                       CONSTRAINT bike_model_not_blank
                           CHECK (length(trim(bike_model)) > 0),

                       CONSTRAINT bike_status_allowed
                           CHECK (current_status IN ('available','rented','maintenance','retired'))
);

-- 3) Kunder
CREATE TABLE customers (
                           customer_id      SERIAL PRIMARY KEY,
                           first_name       VARCHAR(20) NOT NULL,
                           last_name        VARCHAR(30) NOT NULL,
                           phone_number     VARCHAR(20) NOT NULL,
                           email            VARCHAR(50) NOT NULL,
                           registered_date  TIMESTAMPTZ NOT NULL DEFAULT now(),

                           CONSTRAINT first_name_not_blank
                               CHECK (length(trim(first_name)) > 0),

                           CONSTRAINT last_name_not_blank
                               CHECK (length(trim(last_name)) > 0)
);

-- 4) Leieforhold
CREATE TABLE rentals (
                         rental_id         SERIAL PRIMARY KEY,
                         bike_id           INTEGER NOT NULL REFERENCES bikes(bike_id),
                         customer_id       INTEGER NOT NULL REFERENCES customers(customer_id),
                         start_station_id  INTEGER NOT NULL REFERENCES rental_stations(station_id),
                         end_station_id    INTEGER NULL REFERENCES rental_stations(station_id),
                         start_time        TIMESTAMPTZ NOT NULL,
                         end_time          TIMESTAMPTZ NULL,
                         invoice_date      TIMESTAMPTZ NULL,

                         CONSTRAINT rental_time_order
                             CHECK (end_time IS NULL OR end_time > start_time)
);

-- Sett inn testdata
INSERT INTO rental_stations(station_name, station_address)
VALUES ('Universitetet', 'Blindern Oslo'),
       ('Grünerløkka Stasjon', 'Thorvald Meyers gate 10 Oslo'),
       ('Aker Brygge Stasjon', 'Stranden 1 Oslo'),
       ('Sentrum Stasjon', 'Karl Johans gate 1 Oslo'),
       ('Majorstuen Stasjon', 'Bogstadveien 50 Oslo');

INSERT INTO bikes (bike_model, current_status, station_id)
VALUES
    ('Urban Cruiser', 'available', 3),
    ('EcoBike 3000', 'available', 2),
    ('City Bike Pro', 'available', 4);


INSERT INTO customers(first_name, last_name, phone_number, email)
VALUES ('Ole', 'Hansen', '4791234567', 'ole.hansen@example.com'),
       ('Kari', 'Olsen', '4792345678', 'kari.olsen@example.com'),
       ('Per', 'Andersen', '4793456789', 'per.andersen@example.com'),
       ('Lise', 'Johansen', '4794567890', 'lise.johansen@example.com'),
       ('Erik', 'Larsen', '4795678901', 'erik.larsen@example.com'),
       ('Anna', 'Nilsen', '4796789012', 'anna.nilsen@example.com');


-- View for kunde:
CREATE SCHEMA kunde_views;
CREATE VIEW kunde_views.kunde1_view AS
SELECT
    r.bike_id,
    b.bike_model,
    r.start_time,
    rs_end.station_name AS til_stasjon,
    r.end_time - r.start_time AS varighet
FROM rentals r
         JOIN bikes b
              ON r.bike_id = b.bike_id
         INNER JOIN rental_stations rs_start
                    ON r.start_station_id = rs_start.station_id
         INNER JOIN rental_stations rs_end
                    ON r.end_station_id = rs_end.station_id
WHERE r.customer_id = 1;

-- DBA setninger (rolle: kunde, bruker: kunde_1)
CREATE ROLE kunde;
GRANT CONNECT ON DATABASE bike_rental TO kunde;
CREATE USER kunde_1 WITH PASSWORD 'kunde1';

GRANT kunde TO kunde_1;
GRANT USAGE ON SCHEMA kunde_views TO kunde_1;
GRANT SELECT ON kunde_views.kunde1_view TO kunde_1;

REVOKE ALL ON SCHEMA public FROM kunde_1;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM kunde_1;


-- Eventuelt: Opprett indekser for ytelse
-- Vi lager en indeks for å raskt finne ledige sykler på en utleiestasjon:
CREATE INDEX bikes_available_by_station_idx
    ON bikes (station_id)
    WHERE current_status = 'available';


-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;