-- Generate Sample Data

SET foreign_key_checks = 0;

TRUNCATE events;
TRUNCATE seats;
TRUNCATE venues;
TRUNCATE tickets;
TRUNCATE orders;

INSERT INTO venues (name, location) VALUES 
 ('Santa Clara, CA', POINT(-121.9552, 37.3541)),
 ('New York, NY', POINT(-74.0059, 40.7128)),
 ('San Diego, CA',POINT(-117.1611, 32.7157)),
 ('Chicago, IL', POINT(-87.6298, 41.8781)),
 ('Atlanta, GA', POINT(-84.3880, 33.7490)),
 ('Austin, TX', POINT(-97.7431, 30.2672)),
 ('Toronto, Canada', POINT(-79.3832, 43.6532)),
 ('Ottawa, Canada', POINT(-75.6972,45.4215)),
 ('Montreal, Canada',POINT(-73.5673, 45.5017)),
 ('Vancouver, Canada', POINT(-123.1207, 49.2827));

INSERT INTO events (venue_id, name, event_date, thumbnail) VALUES 
((SELECT id FROM venues WHERE name='Santa Clara, CA'), 'Santa Clara MySQL Insights Roadshow', '2017-08-21 08:30:00', 'https://c1.staticflickr.com/4/3852/14918305151_fdbd0b93f1_h.jpg'),
((SELECT id FROM venues WHERE name='New York, NY'), 'New York City MySQL Insights Roadshow', '2017-09-21 08:30:00', 'https://images.unsplash.com/photo-1423655156442-ccc11daa4e99?dpr=1&auto=format&fit=crop&w=1080&h=720&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='San Diego, CA'), 'San Diego MySQL Insights Roadshow', '2017-11-01 08:30:00', 'https://images.unsplash.com/photo-1476673214707-ab4d72a2c9b1?dpr=1&auto=format&fit=crop&w=1080&h=719&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Chicago, IL'), 'Chicago MySQL Insights Roadshow', '2017-12-06 08:30:00', 'https://images.unsplash.com/photo-1496850574977-a4607106a874?dpr=1&auto=format&fit=crop&w=1080&h=1620&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Atlanta, GA'), 'Atlanta MySQL Insights Roadshow', '2018-01-17 08:30:00', 'https://images.unsplash.com/photo-1443557661966-8b4795a6f62c?dpr=1&auto=format&fit=crop&w=1080&h=720&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Austin, TX'), 'Austin MySQL Insights Roadshow', '2017-02-07 08:30:00', 'https://images.unsplash.com/photo-1437021663029-4b6a28719dee?dpr=1&auto=format&fit=crop&w=1080&h=718&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Toronto, Canada'), 'Toronto MySQL Insights Roadshow', '2017-09-21 08:30:00', 'https://images.unsplash.com/photo-1499447318306-5f520878fe20?dpr=1&auto=format&fit=crop&w=1080&h=720&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Ottawa, Canada'), 'Ottawa MySQL Insights Roadshow', '2017-10-24 08:30:00', 'https://images.unsplash.com/photo-1498084393753-b411b2d26b34?dpr=1&auto=format&fit=crop&w=1080&h=608&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Montreal, Canada'), 'Montreal MySQL Insights Roadshow', '2017-10-26 08:30:00', 'https://images.unsplash.com/photo-1470181942237-78ce33fec141?dpr=1&auto=format&fit=crop&w=1080&h=720&q=80&cs=tinysrgb&crop='),
((SELECT id FROM venues WHERE name='Vancouver, Canada'), 'Vancouver MySQL Insights Roadshow', '2017-10-12 08:30:00', 'https://images.unsplash.com/photo-1463678200619-297ab6ac9c13?dpr=1&auto=format&fit=crop&w=1080&h=730&q=80&cs=tinysrgb&crop=');

-- use the same short description and long description
-- for each of the events

UPDATE events SET description="Register now for the MySQL Insights Roadshow.  Be the first to learn about MySQL innovation at Oracle.  
Join us to learn about new developments, meet your peers in the tech industry, and converse with MySQL experts.",
description_extended = "<p>Register now for the MySQL Insights Roadshow.  Be the first to learn about MySQL innovation at Oracle.  
Join us to learn about new developments, meet your peers in the tech industry, and converse with MySQL experts.</p>

<p>Expect to learn about:</p>
<ul>
<li>New MySQL 8.0 development plans</li>
<li>Deploying the latest built-in high-availability solution for MySQL:  MySQL InnoDB Cluster</li>
<li>Securing your database with encryption, auditing, authentication and firewalls</li>
<li>Next-generation MySQL development techniques including JSON, MySQL Document Store and GIS</li>
</ul>

<p>Register now to reserve your seat.</p>";


-- Add 200 seats for the first venue

INSERT INTO seats
 (venue_id) VALUES 
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
 (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1);

-- Quick trick to set seat + row

UPDATE seats SET doc = JSON_OBJECT(
 'seat', (id % 20)+1,
 'row', CEIL(id/20)
 );

-- Copy same seat configuration to the remaining venues

INSERT INTO seats (venue_id, doc) SELECT 2, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 3, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 4, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 5, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 6, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 7, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 8, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 9, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 10, doc FROM seats WHERE venue_id = 1;

-- Generate tickets foreach of the seats
-- At each ofthe events

INSERT INTO tickets (event_id, seat_id)
 SELECT events.id as event_id, seats.id
 FROM events
 INNER JOIN seats ON seats.venue_id=events.venue_id;
