<?php

require_once 'db_meta.php';



function DBconnect() {
    $conn_string = "host=".PGVALUES['host']." port=".PGVALUES['port']." dbname=".PGVALUES['dbname']." user=".PGVALUES['user']." password=".PGVALUES['password']."";
    $GLOBALS['dbconn'] = pg_connect($conn_string) or die('Connection failed');
}

function checkLogin($type, $un, $ps) {
    $query = "SELECT username, password FROM ".($type === "customer" ? "customer" : "employee")
           ." WHERE username = $1 AND password = $2";
    pg_prepare($GLOBALS['dbconn'], 'logincheck', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'logincheck', [$un, $ps]);
    echo $result;
    return pg_num_rows($result) > 0;
}

function getEmployeeSinAndName($username){
    $query = "SELECT employee_sin, name  FROM employee WHERE username = $1 ";
    pg_prepare($GLOBALS['dbconn'], 'getEmployeeSinAndName', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getEmployeeSinAndName', [$username]);
    return (pg_fetch_object($result));
}

function getEmployeeHotel($sin){
    $query = "SELECT * FROM works WHERE works.employee_sin = $1";
    pg_prepare($GLOBALS['dbconn'], 'getEmployeeHotel', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getEmployeeHotel', [$sin]);
    return (pg_fetch_object($result));
}

function getBookings($sin){
    $query = "SELECT * FROM rents WHERE customer_sin = $1 and start_date = CURRENT_DATE ";
    pg_prepare($GLOBALS['dbconn'], 'getBookings', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getBookings', [$sin]);
    // print_r(pg_fetch_object($result));
    // print_r(pg_fetch_object($result));
    // return (pg_fetch_object($result));
    // while($row = pg_fetch_object($result)) {
    //     print_r($row); 
    // }
    return $result;
}

