<?php
    session_start();
    require_once 'db.php';


    // check if someone went straight to this page without logging in
    if (!isset($_SESSION['username']) || !isset($_SESSION['usertype']) || $_SESSION['usertype'] != 'employee') {
        header("location: {$PGVALUES['host']}/Databases-1-Project/login.php");
    }

    DBconnect();





    $user = $_SESSION['username'];
    
    // print_r( getEmployeeInfo($user));
    $empinf = getSinAndName('employee', $user);
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
    $_SESSION['selectedcsin'] = $csin;

    $bookings =(getBookings($csin));
	$bookingsr = pg_fetch_all($bookings);
    echo "bookingsr ";
    print_r( $bookingsr);

    // $bookings =(getBookings($csin));
    // while($row = pg_fetch_object($bookings)) {
    //     print_r($row); 
    // }
    
    // var_dump( getEmployeeHotel($sin));

    // include 'convertbooking.php';

    if (isset($_POST['selected']))
{
	echo "selected!!!";
    echo $_POST['selected'];
    echo '<br>';
    print_r( $bookingsr[ $_POST['selected'] ] );
    $selectedbooking = $bookingsr[ $_POST['selected'] ];
    echo $selectedbooking['hotel_name'];
    // var_dump ($csin, $selectedbooking['room_number'], $selectedbooking['hotel_name'], $selectedbooking['start_date'], $selectedbooking['end_date'], true);
    $r = createRents($csin, $selectedbooking['room_number'], $selectedbooking['hotel_name'],$selectedbooking['start_date'],$selectedbooking['end_date'], true);
    var_dump($r);
    echo '<br>';
    $r2 = deleteBooking($csin, $selectedbooking['room_number'], $selectedbooking['hotel_name'],$selectedbooking['start_date'],$selectedbooking['end_date']);
    var_dump($r2);
    $bookings =(getBookings($csin));
	$bookingsr = pg_fetch_all($bookings);
}

?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels</title>
</head>
<body>
    <h1> <?php echo $hotel ?> Employee Page </h1>
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
    // include 'convertbooking.php'; 
    ?>
    
    <h3>Select which of customer <?php echo $csin ?>'s bookings would would like to convert </h3>

    <h3>Select which of customer <?php echo $csin ?>'s bookings would would like to convert </h3>

    <form action = "<?php echo $_SERVER['PHP_SELF'];?>" method='POST'>
		<table>
			<tr>
				<th>Hotel Name</th>
				<th>Room Number</th>
				<th>Start Date</th>
				<th>End Date</th>
                <th>Select </th>
			</tr>

			<?php
            
            $count=0;
			foreach($bookingsr as $array)
			{
                
			    echo '<tr>
									<td>'. $array['hotel_name'].'</td>
									<td>'. $array['room_number'].'</td>
									<td>'. $array['start_date'].'</td>
									<td>'. $array['end_date'].'</td>
                                    <td><button type="submit" value="'.$count.'" name="selected" >SELECT</button></td>
                                    

			          </tr>';
                $count++;
			}
			?>

		</table>
    </form>
</body>
</html>
