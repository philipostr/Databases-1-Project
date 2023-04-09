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

    return pg_num_rows($result) > 0;
}
