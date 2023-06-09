----------------------------------------------------
--                                                --
--                                                --
--           DATABASE SCHEMA CREATION             --
--                                                --
--                                                --
----------------------------------------------------

-- DROP  table chain CASCADE;
-- Added non-negative check on num_of_hotel
CREATE TABLE chain (
	chain_name VARCHAR(50) PRIMARY KEY, 
	address  VARCHAR(50) NOT NULL,
	num_of_hotel INTEGER NOT NULL CHECK (num_of_hotel >= 0),
	contact_email VARCHAR(50) NOT NULL,
	phone_numbers BIGINT[] NOT NULL
);

-- Changed employee_sin to CHAR(9), added username and password attributes
CREATE TABLE employee (
	employee_sin CHAR(9) PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	address VARCHAR(50) NOT NULL,
	username VARCHAR(50) UNIQUE NOT NULL,
	password VARCHAR(50) NOT NULL
);
-- DROP  table hotel CASCADE;
--PHONE NUM IS BIG INT
-- Added negative check on number_of_rooms, changed manager_sin to CHAR(9), changed category to SMALLINT, added 1-5 check on category
CREATE TABLE hotel (
	hotel_name VARCHAR(50) PRIMARY KEY,
	number_of_rooms INTEGER NOT NULL CHECK (number_of_rooms >= 0),
	manager_sin CHAR(9) NOT NULL,
	address VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
	phone_numbers BIGINT[] NOT NULL,
	category SMALLINT NOT NULL CHECK (category >= 1 AND category <= 5),
	FOREIGN KEY (manager_sin) REFERENCES employee(employee_sin)
);

CREATE TABLE chain_hotel (
	hotel_name  VARCHAR(50) PRIMARY KEY,
	chain_name  VARCHAR(50) NOT NULL,
	FOREIGN KEY (hotel_name) REFERENCES hotel(hotel_name),
	FOREIGN KEY (chain_name) REFERENCES chain(chain_name)
);

-- Changed employee_sin to CHAR(9)
CREATE TABLE works (
	employee_sin CHAR(9) PRIMARY KEY,
	hotel_name  VARCHAR(50) NOT NULL,
	position  VARCHAR(50)[] NOT NULL,
	FOREIGN KEY (hotel_name) REFERENCES hotel(hotel_name),
	FOREIGN KEY (employee_sin) REFERENCES employee(employee_sin)
);

-- Changed customer_sin to CHAR(9), added default getdate() to date_of_registration, added username and password attributes
CREATE TABLE customer (
	customer_sin CHAR(9) PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	address VARCHAR(50) NOT NULL,
	date_of_registration DATE DEFAULT CURRENT_DATE NOT NULL,
	username VARCHAR(50) UNIQUE NOT NULL,
	password VARCHAR(50) NOT NULL
);

-- New function to use for price check in room table
CREATE FUNCTION roomAmount(_hotel_name VARCHAR(50)) RETURNS INTEGER AS
	'SELECT number_of_rooms FROM hotel WHERE hotel_name = _hotel_name;'
	LANGUAGE SQL;

CREATE TYPE amenitiesenum AS ENUM ('Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options');
CREATE TYPE viewenum AS ENUM('Sea', 'Mountain');

-- MADE THE ENUM A TYPE 
-- Added hotel_name attribute (merged room and hotel_room tables) because two hotels can have the same room_number, so it can’t be used as a primary key, added positive check to room_number, added non-negative check to price, changed amenities to related ENUM, changed capacity to TINYINT, added positive check to capacity, changed view to related ENUM, removed NOT NULL from view, added primary key constraint to (hotel_name, room_number)
CREATE TABLE room (
	hotel_name VARCHAR(50) NOT NULL,
	room_number INTEGER NOT NULL CHECK (room_number >= 1 AND room_number <= roomAmount(hotel_name)),
	price NUMERIC(8, 2) NOT NULL CHECK (price >= 0),
	amenities amenitiesenum[] NOT NULL,
	capacity SMALLINT NOT NULL CHECK (capacity >= 1),
	view viewenum,
	extendable BOOLEAN NOT NULL,
	problems VARCHAR(50)[] NOT NULL,
	PRIMARY KEY (hotel_name, room_number),
	FOREIGN KEY (hotel_name) REFERENCES hotel(hotel_name)
);

-- Removed hotel_room table

-- CAN'T SIMPLY REFERENCE room_number BECAUSE IT IS NOT UNIQUE
-- NEED ADD hotel_name AS WELL IF WE WANT TO REFERENCE room
-- Changed customer_sin to CHAR(9), check that end_date is after start_date
CREATE TABLE rents (
	customer_sin CHAR(9) NOT NULL ,
	FOREIGN KEY (customer_sin) REFERENCES customer(customer_sin),
	room_number INTEGER NOT NULL,
	hotel_name VARCHAR(50) NOT NULL,
	FOREIGN KEY (hotel_name, room_number) REFERENCES room(hotel_name, room_number),
	start_date DATE NOT NULL,
	end_date DATE NOT NULL CHECK (start_date < end_date),
	was_booked BOOL NOT NULL,
	PRIMARY KEY (customer_sin, room_number, hotel_name, start_date)
);

-- Changed customer_sin to CHAR(9), check tha end_date is after start_date
CREATE TABLE books (
	customer_sin CHAR(9) NOT NULL,
	FOREIGN KEY (customer_sin) REFERENCES customer(customer_sin),
	room_number INTEGER NOT NULL ,
	hotel_name VARCHAR(50) NOT NULL,
	FOREIGN KEY (hotel_name, room_number) REFERENCES room(hotel_name, room_number),
	start_date DATE NOT NULL,
	end_date DATE NOT NULL  CHECK (start_date < end_date),
	PRIMARY KEY (customer_sin, room_number, hotel_name, start_date)
);

-- Creation of indexes for part 7 
CREATE INDEX index_address ON hotel (address);
CREATE INDEX  index_books_start_date  ON books (start_date);
CREATE INDEX  index_rents_start_date ON rents (start_date);

-- Creation of views for part 9
-- view 1
CREATE VIEW available_rooms as 
SELECT SUBSTRING(address FROM '^([^,]*),') AS city, COUNT(room_number)
FROM hotel NATURAL JOIN room
WHERE (hotel_name, room_number) NOT IN (
	SELECT hotel_name, room_number FROM books
	WHERE CURRENT_DATE >= start_date AND CURRENT_DATE <= end_date
)
GROUP BY city
ORDER BY city;

-- view 2
CREATE VIEW hotel_room_capacities AS
SELECT hotel_name, room_number, capacity FROM room
ORDER BY hotel_name, room_number;


----------------------------------------------------
--                                                --
--                                                --
--               DATABASE POPULATION              --
--                                                --
--                                                --
----------------------------------------------------

INSERT INTO employee VALUES
('123456789', 'John Doe', '123 Main St', 'jdoe', 'password1'),
('234567890', 'Jane Smith', '456 Elm St', 'jsmith', 'password2'),
('345678901', 'Bob Johnson', '789 Oak St', 'bjohnson', 'password3'),
('456789012', 'Samantha Lee', '101 Maple St', 'slee', 'password4'),
('567890123', 'Michael Davis', '555 Pine St', 'mdavis', 'password5'),
('678901234', 'Emily Chen', '222 Walnut St', 'echen', 'password6'),
('789012345', 'David Kim', '444 Birch St', 'dkim', 'password7'),
('890123456', 'Michelle Wong', '777 Cedar St', 'mwong', 'password8'),
('901234567', 'William Li', '888 Beach St', 'wli', 'password9'),
('012345678', 'Sophie Wang', '999 Bay St', 'swang', 'password10'),
('123456780', 'Daniel Brown', '321 Grove St', 'dbrown', 'password11'),
('234567891', 'Jennifer Liu', '654 Hill St', 'jliu', 'password12'),
('345678902', 'Matthew Park', '987 Park St', 'mpark', 'password13'),
('456789013', 'Rachel Chang', '111 Sunset St', 'rchang', 'password14'),
('567890124', 'Edward Kim', '444 Pineapple St', 'ekim', 'password15'),
('678901235', 'Olivia Zhang', '666 Water St', 'ozhang', 'password16'),
('789012346', 'Andrew Chen', '888 Fire St', 'achen', 'password17'),
('890123457', 'Ethan Lee', '1111 Wind St', 'elee', 'password18'),
('901234568', 'Sofia Wong', '2222 Earth St', 'swong', 'password19'),
('012345679', 'Grace Kim', '3333 Air St', 'gkim', 'password20'),
('123456781', 'Jason Wu', '4444 Thunder St', 'jwu', 'password21'),
('234567892', 'Hannah Kim', '5555 Lightning St', 'hkim', 'password22'),
('345678903', 'Aiden Lee', '6666 Storm St', 'alee', 'password23'),
('456789014', 'Victoria Park', '7777 Cloud St', 'vpark', 'password24'),
('567890125', 'Ryan Chen', '8888 Sun St', 'rchen', 'password25'),
('678901236', 'Evelyn Zhang', '9999 Moon St', 'ezhang', 'password26'),
('789012347', 'Steven Kim', '1010 Star St', 'skim', 'password27'),
('890123458', 'Sophie Wong', '1111 Sky St', 'swong1', 'password28'),
('901234569', 'William Chen', '1212 Comet St', 'wchen', 'password29'),
('012345680', 'Olivia Lee', '1313 Galaxy St', 'olee', 'password30'),
('123456791', 'Temilie Kim', '2222 Starlight St', 'tekim', 'password31'),
('234567902', 'David Lee', '3333 Meteor St', 'dlee', 'password32'),
('345678913', 'Samantha Chen', '4444 Nebula St', 'schen', 'password33'),
('456789024', 'Adam Park', '5555 Comet St', 'apark', 'password34'),
('567890135', 'Grace Chen', '6666 Galaxy St', 'gchen', 'password35'),
('678901246', 'William Kim', '7777 Supernova St', 'wkim', 'password36'),
('789012357', 'Sofia Lee', '8888 Cosmic St', 'slee1', 'password37'),
('890123468', 'Anthony Wu', '9999 Eclipse St', 'awu', 'password38'),
('901234579', 'Hay Parky', '1010 Aurora St', 'hpark', 'password39'),
('012345691', 'Ethan Kim', '1212 Orion St', 'ekim1', 'password40');

INSERT INTO hotel VALUES
('The Plaza Hotel', 200, '123456789', 'New York City, 768 5th Ave', 'plaza@hotel.com', '{2125551234,2125555678}', 5),
('Four Seasons Hotel', 300, '234567890', 'Toronto, 60 Yorkville Ave', 'fourseasons@hotel.com', '{4165551234,4165555678}', 5),
('Ritz-Carlton', 400, '345678901', 'Los Angeles, 900 W Olympic Blvd', 'ritzcarlton@hotel.com', '{2135551234,2135555678}', 5),
('Mandarin Oriental', 500, '456789012', 'Atlanta, 3376 Peachtree Rd NE', 'mandarinoriental@hotel.com', '{4045551234,4045555678}', 5),
('The Peninsula', 600, '567890123', 'Chicago, 108 E Superior St', 'peninsula@hotel.com', '{3125551234,3125555678}', 5),
('Fairmont', 700, '678901234', 'Vancouver, 900 W Georgia St', 'fairmont@hotel.com', '{6045551234,6045555678}', 5),
('JW Marriott', 800, '789012345', 'Washington D.C., 1331 Pennsylvania Ave NW', 'jwmarriott@hotel.com', '{2025551234,2025555678}', 5),
('InterContinental', 900, '890123456', 'Miami, 100 Chopin Plaza', 'intercontinental@hotel.com', '{3055551234,3055555678}', 5),
('The Langham', 1000, '901234567', 'Boston, 250 Franklin St', 'langham@hotel.com', '{6175551234,6175555678}', 5),
('Hyatt Regency', 1100, '012345678', 'San Francisco, 5 Embarcadero Center', 'hyattregency@hotel.com', '{4155551234,4155555678}', 5),
('Waldorf Astoria', 1200, '123456780', 'Orlando, 14200 Bonnet Creek Resort Ln', 'waldorf@hotel.com', '{4075551234,4075555678}', 5),
('Jumeirah', 1300, '234567891', 'Dubai, Al Sufouh Road', 'jumeirah@hotel.com', '{971455551234,971455555678}', 5),
('MGM Grand', 1400, '345678902', 'Las Vegas, 3799 S Las Vegas Blvd', 'mgmgrand@hotel.com', '{7025551234,7025555678}', 5),
('Renaissance', 1500, '456789013', 'New York City, 57 E 57th St', 'renaissance@hotel.com', '{2125551234,2125555678}', 5),
('The Ritz-Carlton', 1600, '567890124', 'Montreal, 1228 Sherbrooke St W', 'ritzcarlton2@hotel.com', '{5145551234,5145555678}', 5),
('Royal York Hotel', 500, '234567891', 'Toronto, 100 Front St W', 'ryh@ryh.com', '{4165551234, 6475551234}', 5),
('Fairmont Banff Springs', 300, '789012345', 'Banff, 405 Spray Ave', 'fbs@fbs.com', '{4035551234, 5875551234}', 5),
('Chateau Lake Louise', 250, '012345678', 'Lake Louise, 111 Lake Louise Dr', 'cll@cll.com', '{4035551234, 7805551234}', 5),
('Four Seasons Toronto', 250, '456789012', 'Toronto, 60 Yorkville Ave', 'fst@fst.com', '{4165551234, 6475551234}', 5),
('Ritz-Carlton Montreal', 220, '901234567', 'Montreal, 1228 Sherbrooke St W', 'rcm@rcm.com', '{5145551234, 4385551234}', 5),
('Trump International Hotel & Tower Toronto', 211, '567890123', 'Toronto, 325 Bay St', 'trump@trump.com', '{4165551234, 6475551234}', 4),
('W Montreal', 152, '123456780', 'Montreal, 901 Square Victoria', 'wm@wm.com', '{5145551234, 4385551234}', 4),
('The Hazelton Hotel', 77, '234567890', 'Toronto, 118 Yorkville Ave', 'thh@thh.com', '{4165551234, 6475551234}', 4),
('Rosewood Hotel Georgia', 156, '345678901', 'Vancouver, 801 W Georgia St', 'rhg@rhg.com', '{6045551234, 7785551234}', 4),
('The Ritz-Carlton Toronto', 263, '678901234', 'Toronto, 181 Wellington St W', 'rtc@rtc.com', '{4165551234, 6475551234}', 4),
('The St. Regis Toronto', 258, '890123456', 'Toronto, 325 Bay St', 'stregis@stregis.com', '{4165551234, 6475551234}', 4),
('The Westin Bayshore, Vancouver', 499, '901234567', 'Vancouver, 1601 Bayshore Dr', 'westin@westin.com', '{6045551234, 7785551234}', 3),
('Le Westin Montreal', 455, '012345678', 'Montreal, 270 St Antoine St W', 'lwm@lwm.com', '{5145551234, 4385551234}', 3),
('Hilton Toronto', 200, '345678901', 'Toronto, 145 Richmond St W', 'hiltontoronto@example.com', ARRAY[4165551234, 4165555678], 5),
('Fairmont Royal York', 100, '456789012', 'Toronto, 100 Front St W', 'fairmonttoronto@example.com', ARRAY[4165552345, 4165556789], 5),
('InterContinental Toronto Centre', 150, '567890123', 'Toronto, 225 Front St W', 'intercontoronto@example.com', ARRAY[4165553456, 4165557890], 4),
('Sheraton Centre Toronto Hotel', 250, '678901234', 'Toronto, 123 Queen St W', 'sheratontoronto@example.com', ARRAY[4165554567, 4165558901], 4),
('The Westin Harbour Castle', 175, '789012345', 'Toronto, 1 Harbour Sq', 'westintoronto@example.com', ARRAY[4165555678, 4165559012], 4),
('Delta Hotels by Marriott Toronto', 130, '890123456', 'Toronto, 75 Lower Simcoe St', 'deltatoronto@example.com', ARRAY[4165556789, 4165550123], 4),
('One King West Hotel & Residence', 90, '901234567', 'Toronto, 1 King St W', 'onekingtoronto@example.com', ARRAY[4165557890, 4165551234], 3),
('The Omni King Edward Hotel', 80, '012345678', 'Toronto, 37 King St E', 'omnitoronto@example.com', ARRAY[4165558901, 4165552345], 3),
('Kimpton Saint George Hotel', 60, '123456780', 'Toronto, 280 Bloor St W', 'kimptontoronto@example.com', ARRAY[4165559012, 4165553456], 3),
('The Ritz-Carlton, Toronto', 120, '345678902', 'Toronto, 181 Wellington St W', 'ritzcarltontoronto@example.com', ARRAY[4165551234, 4165555678], 5),
('The Ivy at Verity', 40, '567890124', 'Toronto, 111d Queen St E', 'ivyatveritytoronto@example.com', ARRAY[4165553456, 4165557890], 3),
('The Broadview Hotel', 80, '678901235', 'Toronto, 106 Broadview Ave', 'broadviewtoronto@example.com', ARRAY[4165554567, 4165558901], 3);

INSERT INTO works VALUES
('123456789', 'The Plaza Hotel', '{Manager}'),
('234567890', 'Four Seasons Hotel', '{Manager}'),
('345678901', 'Ritz-Carlton', '{Manager}'),
('456789012', 'Mandarin Oriental', '{Manager}'),
('567890123', 'The Peninsula', '{Manager}'),
('678901234','Fairmont', '{Manager}'),
('789012345', 'JW Marriott', '{Manager}'),
('890123456', 'InterContinental', '{Manager}'),
('901234567', 'The Langham', '{Manager}'),
('012345678', 'Hyatt Regency', '{Manager}'),
('123456780', 'Waldorf Astoria', '{Manager}'),
('234567891', 'Jumeirah', '{Manager}'),
('345678902', 'MGM Grand', '{Manager}'),
('456789013', 'Renaissance', '{Manager}'),
('567890124', 'The Ritz-Carlton', '{Manager}'),
('678901235', 'Royal York Hotel', '{Manager}'),
('789012346', 'Fairmont Banff Springs', '{Manager}'),
('890123457', 'Chateau Lake Louise', '{Manager}'),
('901234568', 'Four Seasons Toronto', '{Manager}'),
('012345679', 'Ritz-Carlton Montreal', '{Manager}'),
('123456781', 'Trump International Hotel & Tower Toronto', '{Manager}'),
('234567892', 'W Montreal', '{Manager}'),
('345678903', 'The Hazelton Hotel', '{Manager}'),
('456789014', 'Rosewood Hotel Georgia', '{Manager}'),
('567890125', 'The Ritz-Carlton Toronto', '{Manager}'),
('678901236', 'The St. Regis Toronto', '{Manager}'),
('789012347', 'The Westin Bayshore, Vancouver', '{Manager}'),
('890123458', 'Le Westin Montreal', '{Manager}'),
('901234569', 'Hilton Toronto', '{Manager}'),
('012345680', 'Fairmont Royal York', '{Manager}'),
('123456791', 'InterContinental Toronto Centre', '{Manager}'),
('234567902', 'Sheraton Centre Toronto Hotel', '{Manager}'),
('345678913', 'The Westin Harbour Castle', '{Manager}'),
('456789024', 'Delta Hotels by Marriott Toronto', '{Manager}'),
('567890135', 'One King West Hotel & Residence', '{Manager}'),
('678901246', 'The Omni King Edward Hotel', '{Manager}'),
('789012357', 'Kimpton Saint George Hotel', '{Manager}'),
('890123468', 'The Ritz-Carlton, Toronto', '{Manager}'),
('901234579', 'The Ivy at Verity', '{Manager}'),
('012345691', 'The Broadview Hotel', '{Manager}');

--update all the manager_sin to be the employee_sin that is in the works relation
UPDATE hotel H SET manager_sin = (SELECT employee_sin FROM works WHERE hotel_name = H.hotel_name);
--check if successfully updated
SELECT H.hotel_name FROM hotel H INNER JOIN works W ON H.manager_sin = W.employee_sin;

INSERT INTO room VALUES
('The Plaza Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Plaza Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Plaza Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Plaza Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Plaza Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Four Seasons Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Four Seasons Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Four Seasons Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Four Seasons Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Four Seasons Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Ritz-Carlton', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Ritz-Carlton', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Mandarin Oriental', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Mandarin Oriental', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Mandarin Oriental', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Mandarin Oriental', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Mandarin Oriental', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Peninsula', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Peninsula', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Peninsula', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Peninsula', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Peninsula', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Fairmont', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Fairmont', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Fairmont', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('JW Marriott', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('JW Marriott', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('JW Marriott', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('JW Marriott', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('JW Marriott', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('InterContinental', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('InterContinental', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('InterContinental', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('InterContinental', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('InterContinental', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Langham', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Langham', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Langham', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Langham', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Langham', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Hyatt Regency', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Hyatt Regency', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Hyatt Regency', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Hyatt Regency', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Hyatt Regency', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Waldorf Astoria', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Waldorf Astoria', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Waldorf Astoria', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Waldorf Astoria', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Waldorf Astoria', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Jumeirah', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Jumeirah', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Jumeirah', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Jumeirah', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Jumeirah', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('MGM Grand', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('MGM Grand', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('MGM Grand', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('MGM Grand', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('MGM Grand', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Renaissance', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Renaissance', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Renaissance', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Renaissance', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Renaissance', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Ritz-Carlton', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Ritz-Carlton', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Royal York Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Royal York Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Royal York Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Royal York Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Royal York Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Fairmont Banff Springs', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont Banff Springs', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Fairmont Banff Springs', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont Banff Springs', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Fairmont Banff Springs', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Chateau Lake Louise', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Chateau Lake Louise', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Chateau Lake Louise', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Chateau Lake Louise', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Chateau Lake Louise', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Four Seasons Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Four Seasons Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Four Seasons Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Four Seasons Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Four Seasons Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Ritz-Carlton Montreal', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton Montreal', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton Montreal', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Ritz-Carlton Montreal', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Ritz-Carlton Montreal', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Trump International Hotel & Tower Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Trump International Hotel & Tower Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Trump International Hotel & Tower Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Trump International Hotel & Tower Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Trump International Hotel & Tower Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('W Montreal', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('W Montreal', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('W Montreal', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('W Montreal', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('W Montreal', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Hazelton Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Hazelton Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Hazelton Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Hazelton Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Hazelton Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Rosewood Hotel Georgia', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Rosewood Hotel Georgia', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Rosewood Hotel Georgia', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Rosewood Hotel Georgia', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Rosewood Hotel Georgia', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Ritz-Carlton Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Ritz-Carlton Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The St. Regis Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The St. Regis Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The St. Regis Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The St. Regis Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The St. Regis Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Westin Bayshore, Vancouver', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Westin Bayshore, Vancouver', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Westin Bayshore, Vancouver', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Westin Bayshore, Vancouver', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Westin Bayshore, Vancouver', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Le Westin Montreal', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Le Westin Montreal', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Le Westin Montreal', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Le Westin Montreal', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Le Westin Montreal', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Hilton Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Hilton Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Hilton Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Hilton Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Hilton Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Fairmont Royal York', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont Royal York', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Fairmont Royal York', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Fairmont Royal York', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Fairmont Royal York', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('InterContinental Toronto Centre', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('InterContinental Toronto Centre', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('InterContinental Toronto Centre', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('InterContinental Toronto Centre', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('InterContinental Toronto Centre', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Sheraton Centre Toronto Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Sheraton Centre Toronto Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Sheraton Centre Toronto Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Sheraton Centre Toronto Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Sheraton Centre Toronto Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Westin Harbour Castle', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Westin Harbour Castle', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Westin Harbour Castle', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Westin Harbour Castle', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Westin Harbour Castle', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Delta Hotels by Marriott Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Delta Hotels by Marriott Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Delta Hotels by Marriott Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Delta Hotels by Marriott Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Delta Hotels by Marriott Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('One King West Hotel & Residence', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('One King West Hotel & Residence', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('One King West Hotel & Residence', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('One King West Hotel & Residence', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('One King West Hotel & Residence', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Omni King Edward Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Omni King Edward Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Omni King Edward Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Omni King Edward Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Omni King Edward Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('Kimpton Saint George Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('Kimpton Saint George Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('Kimpton Saint George Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('Kimpton Saint George Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('Kimpton Saint George Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Ritz-Carlton, Toronto', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton, Toronto', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton, Toronto', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ritz-Carlton, Toronto', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Ritz-Carlton, Toronto', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Ivy at Verity', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ivy at Verity', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Ivy at Verity', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Ivy at Verity', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Ivy at Verity', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']),
('The Broadview Hotel', 1, 150.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Broadview Hotel', 2, 200.00, ARRAY['Toiletries', 'Coffee Kit', 'Included Breakfast', 'Included WiFi']::amenitiesenum[], 3, 'Mountain', TRUE, ARRAY[]::varchar[]),
('The Broadview Hotel', 3, 250.00, ARRAY['Toiletries', 'Coffee Kit', 'Bathrobes', 'Included Breakfast', 'Included WiFi', 'Pillow Options']::amenitiesenum[], 4, 'Sea', TRUE, ARRAY[]::varchar[]),
('The Broadview Hotel', 4, 100.00, ARRAY['Toiletries']::amenitiesenum[], 2, 'Mountain', FALSE, ARRAY['Leaky faucet']),
('The Broadview Hotel', 5, 120.00, ARRAY['Toiletries', 'Included WiFi']::amenitiesenum[], 2, NULL, FALSE, ARRAY['Broken TV']);

INSERT INTO chain VALUES
('Sugar Deluxe', 'Toronto, 25 Pell Street', 8, 'sugardeluxemain@gmail.com', '{6134545999}' ),
('Maple Inn', 'Ottawa, 123 Main Street', 8, 'contact@mapleinn.com', '{6131231234}' ),
('Paradise Away', 'New York, 12 Second Street' , 8, 'admin@paradiseaway.com', '{1231231234}'),
('North Vacations', 'Paris, 12 Premier Street' , 8, 'admin@europevacations.com', '{2221231234}'),
('Reddington Resort', 'Montreal, 5 Sun Street', 8, 'reddingtonresort@main.com', '{6132345989}' );

INSERT INTO chain_hotel VALUES 
('The Plaza Hotel', 'Sugar Deluxe'),
('Four Seasons Hotel', 'Sugar Deluxe'),
('Ritz-Carlton', 'Sugar Deluxe'),
('Mandarin Oriental', 'Sugar Deluxe'),
('The Peninsula', 'Sugar Deluxe'),
('Fairmont', 'Sugar Deluxe'),
('JW Marriott', 'Sugar Deluxe'),
('InterContinental', 'Sugar Deluxe'),
('The Langham', 'Maple Inn'),
('Hyatt Regency', 'Maple Inn'),
('Waldorf Astoria', 'Maple Inn'),
('Jumeirah', 'Maple Inn'),
('MGM Grand', 'Maple Inn'),
('Renaissance', 'Maple Inn'),
('The Ritz-Carlton', 'Maple Inn'),
('Royal York Hotel', 'Maple Inn'),
('Fairmont Banff Springs', 'Paradise Away'),
('Chateau Lake Louise', 'Paradise Away'),
('Four Seasons Toronto', 'Paradise Away'),
('Ritz-Carlton Montreal', 'Paradise Away'),
('Trump International Hotel & Tower Toronto', 'Paradise Away'),
('W Montreal', 'Paradise Away'),
('The Hazelton Hotel', 'Paradise Away'),
('Rosewood Hotel Georgia', 'Paradise Away'),
('The Ritz-Carlton Toronto', 'North Vacations'),
('The St. Regis Toronto', 'North Vacations'),
('The Westin Bayshore, Vancouver', 'North Vacations'),
('Le Westin Montreal', 'North Vacations'),
('Hilton Toronto', 'North Vacations'),
('Fairmont Royal York', 'North Vacations'),
('InterContinental Toronto Centre', 'North Vacations'),
('Sheraton Centre Toronto Hotel', 'North Vacations'),
('The Westin Harbour Castle', 'Reddington Resort'),
('Delta Hotels by Marriott Toronto', 'Reddington Resort'),
('One King West Hotel & Residence', 'Reddington Resort'),
('The Omni King Edward Hotel', 'Reddington Resort'),
('Kimpton Saint George Hotel', 'Reddington Resort'),
('The Ritz-Carlton, Toronto', 'Reddington Resort'),
('The Ivy at Verity', 'Reddington Resort'),
('The Broadview Hotel', 'Reddington Resort');

INSERT INTO customer (customer_sin, name, address, username, password) VALUES
('111111111', 'Alice Smith', '123 Main St, Toronto', 'asmith', 'password1'),
('222222222', 'Bob Johnson', '456 Elm St, New York', 'bjohnson', 'password2'),
('333333333', 'Charlie Brown', '789 Oak St, Los Angeles', 'cbrown', 'password3'),
('444444444', 'David Kim', '101 Maple St, San Francisco', 'dkim', 'password4'),
('555555555', 'Emily Chen', '555 Pine St, Toronto', 'echen', 'password5'),
('666666666', 'Frank Lee', '222 Walnut St, New York', 'flee', 'password6'),
('777777777', 'Grace Wang', '444 Birch St, Los Angeles', 'gwang', 'password7'),
('888888888', 'Henry Davis', '777 Cedar St, San Francisco', 'hdavis', 'password8'),
('999999999', 'Isabella Zhang', '888 Beach St, Toronto', 'izhang', 'password9'),
('000000001', 'Jessica Liu', '999 Bay St, New York', 'jliu', 'password10'),
('111111112', 'Kevin Park', '321 Grove St, Los Angeles', 'kpark', 'password11'),
('222222223', 'Lily Chen', '654 Hill St, San Francisco', 'lchen', 'password12'),
('333333334', 'Michael Brown', '987 Park St, Toronto', 'mbrown', 'password13'),
('444444445', 'Nancy Lee', '111 Sunset St, New York', 'nlee', 'password14'),
('555555556', 'Olivia Wong', '444 Pineapple St, Los Angeles', 'owong', 'password15'),
('666666667', 'Peter Kim', '666 Water St, San Francisco', 'pkim', 'password16'),
('777777778', 'Queenie Zhang', '888 Fire St, Toronto', 'qzhang', 'password17'),
('888888889', 'Rachel Chen', '1111 Wind St, New York', 'rchen', 'password18'),
('999999990', 'Sophia Wang', '2222 Earth St, Los Angeles', 'swang', 'password19'),
('000000002', 'Tony Davis', '3333 Air St, San Francisco', 'tdavis', 'password20');


-- Trigger for after adding a new hotel to an existing chain;
CREATE FUNCTION update_num_of_hotels() RETURNS trigger AS $update_num_of_hotels$
    BEGIN
        UPDATE chain SET num_of_hotel = num_of_hotel + 1 where chain.chain_name = NEW.chain_name;
		RETURN NULL;
    END;
$update_num_of_hotels$ LANGUAGE plpgsql;

CREATE TRIGGER update_num_of_hotels AFTER INSERT ON chain_hotel
    FOR EACH ROW EXECUTE FUNCTION update_num_of_hotels();


-- Trigger for after adding a new room to an existing hotel;
CREATE FUNCTION update_num_of_rooms() RETURNS trigger AS $update_num_of_rooms$
    BEGIN
        UPDATE hotel SET number_of_rooms = number_of_rooms + 1 where hotel.hotel_name = NEW.hotel_name;
		RETURN NULL;
    END;
$update_num_of_rooms$ LANGUAGE plpgsql;

CREATE TRIGGER update_num_of_rooms AFTER INSERT ON room
    FOR EACH ROW EXECUTE FUNCTION update_num_of_rooms();

