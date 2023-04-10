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
    // $query2 = "SELECT username  FROM employee WHERE username =". $username;
    pg_prepare($GLOBALS['dbconn'], 'getEmployeeSinAndName', $query);
    // $result = pg_query($GLOBALS['dbconn'], $query2);
    $result = pg_execute($GLOBALS['dbconn'], 'getEmployeeSinAndName', [$username]);
    
    // echo print_r($result);
    // if (!$result) {
    //     echo "An error occured.\n";
    //     exit;
    // }
    // while ($row = pg_fetch_row($result)) {
    //     print_r($row);
    // }
    return (pg_fetch_row($result));
}

function getEmployeeHotel($sin){
    $query = "SELECT * FROM works WHERE works.employee_sin = $1";
    //  and works.hotel_name= hotel.hotel_name;";
    pg_prepare($GLOBALS['dbconn'], 'getEmployeeHotel', $query);
    $result = pg_execute($GLOBALS['dbconn'], 'getEmployeeHotel', [$sin]);
    
    return (pg_fetch_row($result));
}