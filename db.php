<?php

require_once 'db_meta.php';



function DBconnect() {
    $conn_string = "host=".PGVALUES['host']." port=".PGVALUES['port']." dbname=".PGVALUES['dbname']." user=".PGVALUES['user']." password=".PGVALUES['password'];
    $GLOBALS['dbconn'] = pg_connect($conn_string) or die('Connection failed');
}

// Used in login.php
function checkLogin($type, $un, $ps) {
    $query = "SELECT username, password FROM ".($type === "customer" ? "customer" : "employee")
           ." WHERE username = $1 AND password = $2";
    pg_prepare($GLOBALS['dbconn'], 'logincheck', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'logincheck', [$un, $ps]);
    //echo $result;
    return pg_num_rows($result) > 0;
}

// Used in employee.php and customer.php
function getSinAndName($usertype, $username){
    if ($usertype == 'employee') {
        $query = "SELECT employee_sin, name FROM employee WHERE username = $1";
    } elseif ($usertype == 'customer') {
        $query = "SELECT customer_sin, name FROM customer WHERE username = $1";
    }
    
    pg_prepare($GLOBALS['dbconn'], 'getSinAndName', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getSinAndName', [$username]);
    return (pg_fetch_object($result));
}

// Used in employee.php
function getEmployeeHotel($sin){
    $query = "SELECT * FROM works WHERE works.employee_sin = $1";
    pg_prepare($GLOBALS['dbconn'], 'getEmployeeHotel', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getEmployeeHotel', [$sin]);
    return (pg_fetch_object($result));
}

// Used in employee.php
function getBookings($sin){
    $query = "SELECT * FROM books WHERE customer_sin = $1 and start_date = CURRENT_DATE ";
    // pg_prepare($GLOBALS['dbconn'], 'getBookings', $query);
    // $result = pg_execute($GLOBALS['dbconn'], 'getBookings', [$sin]);
    $result = pg_query_params($GLOBALS['dbconn'], $query , [$sin]);
    
    return $result;
}


function deleteBooking($sin, $rn, $hn, $sd, $ed){
    $query = "DELETE FROM books WHERE customer_sin = $1 and  room_number = $2 and  hotel_name = $3 and start_date =$4 and end_date = $5 ";
    pg_prepare($GLOBALS['dbconn'], 'deleteBooking', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'deleteBooking', [$sin, $rn, $hn, $sd, $ed]);
    return $result;
}

function getRents($sin){
    $query = "SELECT * FROM rents WHERE customer_sin = $1 and start_date = CURRENT_DATE ";
    // pg_prepare($GLOBALS['dbconn'], 'getRents', $query);
    // $result = pg_execute($GLOBALS['dbconn'], 'getRents', [$sin]);
    $result = pg_query_params($GLOBALS['dbconn'], $query , [$sin]);
    
    return $result;

}

function createRents($sin, $rn, $hn, $sd, $ed, $was_booked){
    $query = "insert into rents (customer_sin, room_number, hotel_name, start_date, end_date, was_booked)
    VALUES ($1, $2, $3, $4, $5, $6)";
    pg_prepare($GLOBALS['dbconn'], 'createRents', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'createRents', [$sin, $rn, $hn, $sd, $ed, $was_booked]);
    echo "result:";
    var_dump($result);
    return (pg_fetch_object($result));
}
// insert into rents (customer_sin, room_number, hotel_name, start_date, end_date, was_booked)
// VALUES
// ('111111111', 3, 'The Plaza Hotel', '2023-04-11', '2023-04-12', true);


// Used in customer.php
function getView1() {
    $query = "SELECT * FROM available_rooms";
    pg_prepare($GLOBALS['dbconn'], 'getView1', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getView1', []);
    return pg_fetch_all($result);
}

// Used in customer.php
function getPriceExtremes() {
    $query = "SELECT MIN(price), MAX(price) FROM room";
    pg_prepare($GLOBALS['dbconn'], 'getPriceExtremes', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getPriceExtremes', []);
    return pg_fetch_object($result);
}

// Used in customer.php
function getMaxCapacity() {
    $query = "SELECT MAX(capacity) FROM room";
    pg_prepare($GLOBALS['dbconn'], 'getMaxCapacity', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getMaxCapacity', []);
    return pg_fetch_object($result);
}

// Used in customer.php
function getRoomsExtremes() {
    $query = "SELECT MIN(number_of_rooms), MAX(number_of_rooms) FROM hotel";
    pg_prepare($GLOBALS['dbconn'], 'getRoomsExtremes', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getRoomsExtremes', []);
    return pg_fetch_object($result);
}

// Used in searchResults.php
function getSearchResults($startDate, $endDate, $area, $chain, $minCat, $maxCat, $minCap, $maxPrice, $maxRooms) {
    $areaCheck = $area.'%';
    $query = "
    SELECT R.*, C.chain_name, H.address
    FROM room R
    INNER JOIN hotel H ON R.hotel_name = H.hotel_name
    INNER JOIN chain_hotel C ON H.hotel_name = C.hotel_name WHERE
    NOT EXISTS (SELECT start_date FROM books WHERE start_date < $1 AND end_date > $1)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date < $1 AND end_date > $1)
    AND NOT EXISTS (SELECT start_date FROM books WHERE start_date < $2 AND end_date > $2)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date < $2 AND end_date > $2)
    AND NOT EXISTS (SELECT start_date FROM books WHERE start_date > $1 AND end_date < $2)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date > $1 AND end_date < $2)
    AND H.address LIKE $3 "
    .($chain=='any' ? "AND $4 = $4" : "AND C.chain_name = $4")
    ." AND H.category >= $5 AND H.category <= $6
    AND R.capacity >= $7 "
    .($maxPrice==-1 ? "AND $8 = $8 " : "AND R.price <= $8 ")
    .($maxRooms==-1 ? "AND $9 = $9;" : "AND H.number_of_rooms <= $9;");
    pg_prepare($GLOBALS['dbconn'], 'getSearchResults', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getSearchResults', [$startDate, $endDate, $areaCheck, $chain, $minCat, $maxCat, $minCap, $maxPrice, $maxRooms]);
    return pg_fetch_all($result);
}

// Used in submitBooking.php
function createBooks($sin, $rn, $hn, $sd, $ed){
    $query = "INSERT INTO books VALUES ($1, $2, $3, $4, $5)";
    pg_prepare($GLOBALS['dbconn'], 'createBooks', $query);
    pg_execute($GLOBALS['dbconn'], 'createBooks', [$sin, $rn, $hn, $sd, $ed]);
    //echo '<p>'.$sin.' '.$rn.' '.$hn.' '.$sd.' '.$ed.'</p>';
}

getAvailableRoomsForHotel($startDate, $endDate, $hotel){
    $query = "SELECT R.*, C.chain_name, H.address
    FROM room R
    INNER JOIN hotel H ON R.hotel_name = H.hotel_name
    INNER JOIN chain_hotel C ON H.hotel_name = C.hotel_name WHERE
    NOT EXISTS (SELECT start_date FROM books WHERE start_date < $1 AND end_date > $1)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date < $1 AND end_date > $1)
    AND NOT EXISTS (SELECT start_date FROM books WHERE start_date < $2 AND end_date > $2)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date < $2 AND end_date > $2)
    AND NOT EXISTS (SELECT start_date FROM books WHERE start_date > $1 AND end_date < $2)
    AND NOT EXISTS (SELECT start_date FROM rents WHERE start_date > $1 AND end_date < $2)
    and WHERE H.hotel_name= $3";
    pg_prepare($GLOBALS['dbconn'], 'createBooks', $query);
    pg_execute($GLOBALS['dbconn'], 'createBooks', [$startDate, $endDate, $hotel]);
    return pg_fetch_all($result);
}