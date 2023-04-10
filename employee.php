<?php
    session_start();
    require_once 'db.php';
    DBconnect();





    $user = $_SESSION['username'];
    
    // print_r( getEmployeeInfo($user));
    $empinf = ( getEmployeeSinAndName($user) );
    // var_dump($empinf);
    $sin = $empinf [0];
    $name = $empinf [1];
    $r = ( getEmployeeHotel($sin) );
    $hotel = $r[1];
    $position= $r[2];
    // echo "<br/> <br/>";
    var_dump($r);
    // var_dump( getEmployeeHotel($sin));


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
</body>
</html>
