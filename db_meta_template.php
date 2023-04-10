<?php

/*
        CONNECTION refers to the connection tab in the
        properties of your PostgreSQL 15 server (or whatever 
        server you created the database) in pgAdmin.
*/

define('PGVALUES', [

    'host' => 'localhost', // check in CONNECTION
    'port' => 5432, // check in CONNECTION
    'dbname' => 'DatabaseProject', // name given to your created database
    'user' => 'postgres', // check in CONNECTION
    'password' => '' // password used to access pgAdmin

]);
