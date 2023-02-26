-- Create Table --

CREATE TABLE athlete_event_results (
	edition	VARCHAR,
	edition_id	INTEGER,
	country_noc	VARCHAR,
	sport	VARCHAR,
	event	VARCHAR,
	result_id	VARCHAR,
	athlete	VARCHAR,
	athlete_id	INTEGER,
	pos	VARCHAR,
	medal	VARCHAR,
	isTeamSport	VARCHAR
);

CREATE TABLE games (
	edition	VARCHAR,
	edition_id	INTEGER,
	edition_url	VARCHAR,
	season	VARCHAR,
	year	INTEGER,
	city	VARCHAR,
	country_flag_url	VARCHAR,
	country_noc	VARCHAR,
	start_date	VARCHAR,
	end_date	VARCHAR,
	isHeld	VARCHAR,
	competition_start_date	VARCHAR,
	competition_end_date	VARCHAR
);

CREATE TABLE athlete_bio (
	athlete_id	INTEGER,
	name	VARCHAR,
	sex	VARCHAR,
	born	VARCHAR,
	height	VARCHAR,
	weight	VARCHAR,
	country	VARCHAR,
	country_noc	VARCHAR,
	description	VARCHAR,
	special_notes	VARCHAR
);

CREATE TABLE country (
	country_noc	VARCHAR,
	country	VARCHAR
);

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------



-- Data Cleaning and Table Relationship -- 

-- Create Primary Key -- 
ALTER TABLE athlete_bio ADD PRIMARY KEY (athlete_id);
ALTER TABLE games ADD PRIMARY KEY (edition_id);
DELETE FROM country WHERE country = 'ROC'; -- Harus diremove untuk bisa membuat primary key karena country_id sama namun country berbeda, sehingga diremove karena kode tersebut untuk country yang sama--
ALTER TABLE country ADD PRIMARY KEY (country_noc);


-- Create Foreign Key --
UPDATE athlete_bio set country_noc='SUI' WHERE athlete_id = '97014'; -- diubah agar bisa dilakukan foreign key, dan perubahan ini saya lakukan dengan melihat informasi pada https://olympics.com/en/athletes/bernhard-russi -- 
UPDATE athlete_bio set country='Switzerland' WHERE athlete_id = '97014';

UPDATE athlete_bio set country_noc='ITA' WHERE athlete_id = '97272'; -- diubah agarbisa dilakukan foreign key, dan perubahan ini saya lakukan dengan melihat informasi pada https://olympics.com/en/athletes/helmuth-schmalzl -- 
UPDATE athlete_bio set country='Italy' WHERE athlete_id = '97272';

ALTER TABLE athlete_bio ADD FOREIGN KEY (country_noc)  
REFERENCES country (country_noc);

INSERT INTO games (edition, edition_id, edition_url, year, season, city,
				  country_flag_url, country_noc, start_date, end_date, 
				  competition_start_date, competition_end_date)
VALUES 
('1956 Equestrian Olympics', 48,'/editions/48',1956, 'Equestrian', 'Stockholm',
 '/images/flags/SWE.png', 'SWE', '1956-06-10', '1956-06-17', '1956-06-11', '1956-06-17'),
('1906  Intercalated Games', 4, '/editions/4', 1906, 'Intercalated Games', 'Athina', 
'/images/flags/GRE.png', 'GRE', '1906-04-22', '1906-05-02', '1906-04-22', '1906-05-02')

ALTER TABLE athlete_event_results ADD FOREIGN KEY (edition_id)
REFERENCES games (edition_id);

ALTER TABLE athlete_event_results ADD FOREIGN KEY (country_noc)
REFERENCES country (country_noc);

ALTER TABLE games ADD FOREIGN KEY (country_noc) 
REFERENCES country (country_noc);

ALTER TABLE athlete_event_results ADD FOREIGN KEY (athlete_id)
REFERENCES athlete_bio (athlete_id);
 
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


