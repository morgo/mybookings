-- Generate Sample Data
-- Requires MySQL 8.0

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


-- Our venue has a capacity of ~70K seats
-- There are 3 levels, and several sections

-- 36 sections on Level1 (15K people)
-- 47 sections on Level2 (30K people)
-- 47 sections on Level3 (30K people)

-- Each seat has the following properties:
-- section.  i.e. 101
-- row i.e. 3
-- seat i.e. 5
-- Properties:
--  - Entrance Number: 5
--  - Accessible Seat: True
--  - Distance to Emergency Exits
--  - Ammenities: {food, washroom, food, washroom}

SET cte_max_recursion_depth = 100000;

-- Insert Level 1 (14.4K people)
-- 400 people per section
-- 20*20 layout

INSERT INTO seats
 (venue_id, doc)
WITH RECURSIVE t1 AS (
 SELECT 1 as n FROM dual
 UNION ALL
 SELECT n+1 FROM t1 WHERE n<14400
)
SELECT 1, JSON_OBJECT(
  'section', CAST(CONCAT(1, LPAD((n % 36 + 1), 2, 0)) as signed),
  'row', FLOOR(n/36)%20+1,
  'seat', FLOOR((n/36)/20)+1,
  'properties', 
    JSON_OBJECT(
      'accessible', false, 
      'entrance_number', 4, 
      'amenities',  JSON_ARRAY(
  JSON_OBJECT('type', 'washroom', 'distance_in_meters', RAND()*200+10),
  JSON_OBJECT('type', 'bar', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'snacks', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'souvenirs', 'distance_in_meters', RAND()*400+10)
  ),
      'emergency_exits',  JSON_ARRAY(
  JSON_OBJECT('exit 1', RAND()*500+10),
  JSON_OBJECT('exit 2', RAND()*1000+10),
  JSON_OBJECT('exit 3', RAND()*2000+10),
  JSON_OBJECT('exit 4', RAND()*3000+10),
  JSON_OBJECT('exit 5', RAND()*3000+10)
  )
    )
) FROM t1;

-- Insert Level 2
-- 47 sections
-- 600 people per section
-- 20*30 (r) layout

INSERT INTO seats
 (venue_id, doc)
WITH RECURSIVE t1 AS (
 SELECT 1 as n FROM dual
 UNION ALL
 SELECT n+1 FROM t1 WHERE n<28200
)
SELECT 1, JSON_OBJECT(
  'section', CAST(CONCAT(2, LPAD((n % 47 + 1), 2, 0)) as signed),
  'row', FLOOR(n/47)%30+1,
  'seat', FLOOR((n/47)/20)+1,
  'properties', 
    JSON_OBJECT(
      'accessible', false, 
      'entrance_number', 4, 
      'amenities',  JSON_ARRAY(
  JSON_OBJECT('type', 'washroom', 'distance_in_meters', RAND()*200+10),
  JSON_OBJECT('type', 'bar', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'snacks', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'souvenirs', 'distance_in_meters', RAND()*400+10)
  ),
      'emergency_exits',  JSON_ARRAY(
  JSON_OBJECT('exit 1', RAND()*500+10),
  JSON_OBJECT('exit 2', RAND()*1000+10),
  JSON_OBJECT('exit 3', RAND()*2000+10),
  JSON_OBJECT('exit 4', RAND()*3000+10),
  JSON_OBJECT('exit 5', RAND()*3000+10)
  )
    )
) FROM t1;


-- Insert Level 3
-- 47 sections
-- 600 people per section
-- 20*30 (r) layout

INSERT INTO seats
 (venue_id, doc)
WITH RECURSIVE t1 AS (
 SELECT 1 as n FROM dual
 UNION ALL
 SELECT n+1 FROM t1 WHERE n<28200
)
SELECT 1, JSON_OBJECT(
  'section', CAST(CONCAT(3, LPAD((n % 47 + 1), 2, 0)) as signed),
  'row', FLOOR(n/47)%30+1,
  'seat', FLOOR((n/47)/20)+1,
  'properties', 
    JSON_OBJECT(
      'accessible', false, 
      'entrance_number', 4, 
      'amenities',  JSON_ARRAY(
  JSON_OBJECT('type', 'washroom', 'distance_in_meters', RAND()*200+10),
  JSON_OBJECT('type', 'bar', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'snacks', 'distance_in_meters', RAND()*200+10),  
  JSON_OBJECT('type', 'souvenirs', 'distance_in_meters', RAND()*400+10)
  ),
      'emergency_exits',  JSON_ARRAY(
  JSON_OBJECT('exit 1', RAND()*500+10),
  JSON_OBJECT('exit 2', RAND()*1000+10),
  JSON_OBJECT('exit 3', RAND()*2000+10),
  JSON_OBJECT('exit 4', RAND()*3000+10),
  JSON_OBJECT('exit 5', RAND()*3000+10)
  )
    )
) FROM t1;

-- Update some meta data
-- Sections 101


-- Entrance 2:
-- 108-117
-- 214 -226
-- 314 -326

-- Entrance 3:
-- 118-125
-- 226-235
-- 326-335

-- Entrance 4:
-- default 

-- Entrance 1:
-- Sections 101-107
-- Sections 201-213
-- Sections 301-313

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 101;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 102;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 103;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 104;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 105;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 106;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 107;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 108;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 109;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 110;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 111;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 112;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 113;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 114;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 115;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 116;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 117;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 118;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 119;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 120;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 121;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 122;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 123;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 124;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 125;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 201;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 202;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 203;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 204;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 205;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 206;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 207;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 208;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 209;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 210;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 211;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 212;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 213;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 214;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 215;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 216;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 217;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 218;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 219;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 220;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 221;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 222;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 223;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 224;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 225;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 226;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 227;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 228;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 229;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 230;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 231;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 232;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 233;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 234;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 235;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 301;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 302;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 303;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 304;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 305;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 306;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 307;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 308;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 309;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 310;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 311;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 312;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 1) WHERE doc->"$.section" = 313;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 314;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 315;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 316;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 317;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 318;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 319;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 320;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 321;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 322;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 323;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 324;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 325;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 2) WHERE doc->"$.section" = 326;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 327;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 328;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 329;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 330;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 331;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 332;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 333;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 334;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.entrance_number", 3) WHERE doc->"$.section" = 335;


-- sections 101-106 rows 20, seats 19&20 are accessible

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 101 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 101 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 102 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 102 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 103 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 103 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 104 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 104 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 105 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 105 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 106 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 106 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

-- sections 201-213 rows 30, seats 19&20 are accessible

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 201 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 201 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 202 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 202 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 203 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 203 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 204 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 204 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 205 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 205 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 206 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 206 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 207 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 207 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 208 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 208 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 209 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 209 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 210 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 210 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 211 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 211 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 212 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 212 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 213 AND doc->"$.seat" = 19 AND doc->"$.row" = 20;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 213 AND doc->"$.seat" = 20 AND doc->"$.row" = 20;

-- sections 301-307 rows 1, seats 19&20 are accessible

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 301 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 301 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 302 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 302 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 303 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 303 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 304 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 304 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 305 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 305 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 306 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 306 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;

UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 307 AND doc->"$.seat" = 19 AND doc->"$.row" = 1;
UPDATE seats SET doc = JSON_REPLACE(doc, "$.properties.accessible", true)
WHERE doc->"$.section" = 307 AND doc->"$.seat" = 20 AND doc->"$.row" = 1;



-- Copy same seat configuration to the remaining venues
/*
INSERT INTO seats (venue_id, doc) SELECT 2, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 3, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 4, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 5, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 6, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 7, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 8, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 9, doc FROM seats WHERE venue_id = 1;
INSERT INTO seats (venue_id, doc) SELECT 10, doc FROM seats WHERE venue_id = 1;
*/


-- Generate tickets foreach of the seats
-- At each ofthe events
#ALTER TABLE tickets ADD doc JSON;
#ALTER TABLE tickets ADD row_no INT AS (doc->"$.row"), ADD INDEX (row_no);
#ALTER TABLE tickets ADD seat_no INT AS (doc->"$.seat"), ADD INDEX (seat_no);
#ALTER TABLE tickets ADD section_no INT as (doc->"$.section"), ADD INDEX(section_no);


INSERT INTO tickets (event_id, seat_id, doc)
 SELECT events.id as event_id, seats.id, seats.doc
 FROM events
 INNER JOIN seats ON seats.venue_id=events.venue_id;
