-- Added non-negative check on num_of_hotel
CREATE TABLE chain (
chain_name VARCHAR(50) PRIMARY KEY, 
address  VARCHAR(50) NOT NULL,
num_of_hotel INTEGER NOT NULL CHECK (num_of_hotel >= 0),
contact_email VARCHAR(50) NOT NULL,
phone_numbers INTEGER[] NOT NULL
);

-- Changed employee_sin to CHAR(9), added username and password attributes
CREATE TABLE employee (
	employee_sin CHAR(9) PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	address VARCHAR(50) NOT NULL,
	username VARCHAR(50) UNIQUE NOT NULL,
	password VARCHAR(50) NOT NULL
);

-- Added negative check on number_of_rooms, changed manager_sin to CHAR(9), changed category to SMALLINT, added 1-5 check on category
CREATE TABLE hotel (
	hotel_name VARCHAR(50) PRIMARY KEY,
	number_of_rooms INTEGER NOT NULL CHECK (number_of_rooms >= 0),
	manager_sin CHAR(9) NOT NULL,
	address VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
	phone_numbers INTEGER[] NOT NULL,
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
CREATE FUNCTION roomAmount(_hotel_name VARCHAR(50)) RETURNS INTEGER
	AS 'SELECT number_of_rooms FROM hotel WHERE hotel_name = _hotel_name;'
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
	PRIMARY KEY (customer_sin, room_number, start_date)
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
	PRIMARY KEY (customer_sin, room_number, start_date)
);