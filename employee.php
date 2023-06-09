<?php
    session_start();
    require_once 'db.php';


    // check if someone went straight to this page without logging in
    if (!isset($_SESSION['username']) || !isset($_SESSION['usertype']) || $_SESSION['usertype'] != 'employee') {
        header("location: {$PGVALUES['host']}/Databases-1-Project/login.php");
    }

    DBconnect();





    $user = $_SESSION['username'];
    $empinf = getSinAndName('employee', $user);
    // var_dump($empinf);
    $esin = $empinf->employee_sin;
    $name = $empinf ->name;
    $r = ( getEmployeeHotel($esin) );
    $hotel = $r -> hotel_name;
    $position= $r -> position;    
    $_SESSION['selectedhotel'] = $hotel;

    if (isset($_POST['customersin']))
    {
        $csin =  $_POST['customersin'];
        $_SESSION['selectedcsin'] = $csin;
        $customername = getCustomerNameFromSin($_POST['customersin']);
        
    }
    if (isset($_POST['convert']))
    {
        $_SESSION['employee_choice'] = "convert";
        
    }
    if (isset($_POST['newrent']))
    {
        $_SESSION['employee_choice'] = "newrent";
    }

    



?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels</title>
</head>
<body>
    <form method="post" action="login.php">
        <input name="logout" type="submit" value="Log out">
    </form>
    <h1> <?php echo $hotel ?> Employee Page </h1>
    <h2>Welcome, <?php echo $name ." ". $position ?> </h2>

    
    <form method="POST" action="">
        <label>Customer SIN: 
            <input name="customersin" type="text" placeholder="sin" value="<?php echo isset($_SESSION['selectedcsin'])? $_SESSION['selectedcsin'] : ''?>" required>
        </label><br>
        
        <input name="convert" type="submit" value="Covert booking to renting">
        <br>
        <input name="newrent" type="submit" value="Rent without booking">
        <p><?php echo isset($problem) ? $problem : '' ?></p>
    </form>

    <?php
 
    $isvalidsin = false;
    if (isset($_SESSION['selectedcsin'])){
        $checksin = getCustomerNameFromSin($_SESSION['selectedcsin']);        
        if (pg_num_rows($checksin) <= 0 ){
            echo "<h2>There are no customers with that SIN. Please try another.</h2>";
        }
        else{
            $cname = pg_fetch_object($checksin)->name;
            echo "<h2> Displaying information for customer ".$_SESSION['selectedcsin'].", ". $cname." </h2>";
            $isvalidsin = true;
        }        
    }
    
    if ( $isvalidsin and isset($_SESSION['employee_choice']) and $_SESSION['employee_choice'] == 'convert')
    {

        $csin = $_SESSION['selectedcsin'];
        $bookings = getBookings($csin, $hotel);
        $bookingsr = pg_fetch_all($bookings);

        $rents =(getRents($csin, $hotel));
        $rentsr = pg_fetch_all($rents);
  
        if (isset($_POST['selected']))
        {
            // echo "selected!!!";
            // print_r( $bookingsr[ $_POST['selected'] ] );
            $selectedbooking = $bookingsr[ $_POST['selected'] ];
            $r = createRents($csin, $selectedbooking['room_number'], $selectedbooking['hotel_name'],$selectedbooking['start_date'],$selectedbooking['end_date'], true);
            $r2 = deleteBooking($csin, $selectedbooking['room_number'], $selectedbooking['hotel_name'],$selectedbooking['start_date'],$selectedbooking['end_date']);
   
            $bookings =(getBookings($csin, $hotel));
            $bookingsr = pg_fetch_all($bookings);
            $rents =(getRents($csin, $hotel));
            $rentsr = pg_fetch_all($rents);
        }

    ?>
    
    <h3>Select which of customer <?php echo $csin ?>'s bookings would would like to convert </h3>

    <form action = "<?php echo $_SERVER['PHP_SELF'];?>" method='POST'>
		<table>
			<tr>
				<!-- <th>Hotel Name</th> -->
				<th>Room Number</th>
				<th>Start Date</th>
				<th>End Date</th>
                <th>Select </th>
			</tr>

			<?php
            
            //false when no results
            if ($bookingsr != false)
            {
                $count=0;
			foreach($bookingsr as $array)
			{                
			    echo '<tr>
                <!--	<td>'. $array['hotel_name'].'</td>-->
									<td>'. $array['room_number'].'</td>
									<td>'. $array['start_date'].'</td>
									<td>'. $array['end_date'].'</td>
                                    <td><button type="submit" value="'.$count.'" name="selected" >SELECT</button></td>
			          </tr>';
                $count++;
			}
            }
            else{
                echo '<tr><td>none</td></tr>';
            }
			?>

		</table>
    </form>
    <br><br>

    <h3>Customer <?php echo $csin ?> rented the following today: </h3>

    <table>
			<tr>
				<!-- <th>Hotel Name</th> -->
				<th>Room Number</th>
				<th>Start Date</th>
				<th>End Date</th>
                <th>Was a Booking</th>
			</tr>

			<?php
            
            if ($rentsr != false)
            {
			foreach($rentsr as $array)
			{                
			    echo '<tr>
                <!-- 	<td>'. $array['hotel_name'].'</td> -->
									<td>'. $array['room_number'].'</td>
									<td>'. $array['start_date'].'</td>
									<td>'. $array['end_date'].'</td>
                                    <td>'. ($array['was_booked']? 'true' : 'false') . '</td>

			          </tr>';
			}
            }
            else{
                echo '<tr><td>none</td></tr>';
            }
			?>

	</table>
    <?php
    }
    if (  $isvalidsin and isset($_SESSION['employee_choice']) and $_SESSION['employee_choice'] == 'newrent')
    {
        include 'rentWithoutBooking.php';
    }
    ?>

</body>
</html>
