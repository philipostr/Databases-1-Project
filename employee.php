<?php
    session_start();
    require_once 'db.php';
    DBconnect();





    $user = $_SESSION['username'];
    
    // print_r( getEmployeeInfo($user));
    $empinf = ( getEmployeeSinAndName($user) );
    // var_dump($empinf);
    $esin = $empinf->employee_sin;
    $name = $empinf ->name;
    $r = ( getEmployeeHotel($esin) );
    $hotel = $r -> hotel_name;
    $position= $r -> position;
    // echo "<br/> <br/>";
    var_dump($r);
    echo "<br/> <br/>";
    $csin ="111111111";
    $bookings =(getBookings($csin));
    while($row = pg_fetch_object($bookings)) {
        print_r($row); 
    }
    
    // var_dump( getEmployeeHotel($sin));

    // include 'convertbooking.php';

?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels</title>
</head>
<body>
    <h1> <?php echo $hotel ?>  </h1>
    <h2>Welcome, <?php echo $name ." ". $position ?> </h2>

    <!-- <button>Covert booking to renting</button>
    <button>Rent without booking</button> -->
    <form method="POST" action="">
        <label>Customer SIN: 
            <input name="customersin" type="text" placeholder="sin" required>
        </label><br>
        
        <input name="login" type="submit" value="Covert booking to renting">
        <br>
        <input name="login" type="submit" value="Rent without booking">
        <p><?php echo isset($problem) ? $problem : '' ?></p>
    </form>

    <?php
    include 'convertbooking.php'; 
    ?>
</body>
</html>
