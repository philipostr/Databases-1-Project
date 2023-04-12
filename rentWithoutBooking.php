<?php
    //session_start();
    require_once 'db.php';
    DBconnect();

    
?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels</title>
</head>

<?php
    $csin = $_SESSION['selectedcsin'];
    $hotel = $_SESSION['selectedhotel'];
    $availableRooms = "";
    // $startDate= date("Y-m-d");
    // $endDate="";
    // echo $csin;
    // echo $hotel;
    // echo "SUCCESS";
    
    if (isset($_POST['roomsA'])){
        //$roomNum = $_POST['roomNum'];
        $startDate = $_POST['startDate'];
        $endDate = $_POST['endDate'];
        $_SESSION['selectedSD'] = $startDate;
        $_SESSION['selectedED'] = $endDate;
        if (validateDate($startDate, $endDate)){
            $availableRooms =(getAvailableRoomsForHotel($startDate, $endDate, $hotel));
        }
        else{
            echo "invalid Date";
        }
        //echo $roomNum;
        //echo $startDate;
        //echo $endDate;
        
        //echo $availableRooms;
        // if(createRents($csin, $roomNum, $hotel, $startDate, $endDate, "false")){
        //     echo "SUCCESS";
        // }


        //var_dump(getAvailableRoomsForHotel($startDate, $endDate, $hotel));

    }
    
    if (isset($_POST['selected'])){
        $startDate = $_SESSION['selectedSD'];
        $endDate = $_SESSION['selectedED'];
        //$selectedroom = $_POST['selected'];
        $availableRooms =(getAvailableRoomsForHotel($startDate, $endDate, $hotel));
        $selectedroom = $availableRooms[ $_POST['selected'] ];
        //echo $selectedroom;
        
        //echo 'HIIIII <br><br><br><br><br>';
        
        //var_dump($_POST['selected']);
        //echo 'Here <br>';
        //var_dump($selectedroom);
        //echo 'Here2 <br>';
        //var_dump($availableRooms);
        //echo $startDate;
        //echo $endDate;
        createRents($csin, $selectedroom['room_number'], $hotel, $startDate, $endDate, "false");
        echo "Rent Successfull!";
    }

    //createRents($sin, $rn, $hn, $sd, $ed, $was_booked)
    
?>

<body>
    <h3>RENTING WIHTOUT BOOKING <?php $hotel?></h3>
    <form method="POST">
        <!-- <label>
            <b>Room Number</b> <input name="roomNum" type="number" min=1 required>
        </label> -->

        <label>
            <b>Start Date</b> <input name="startDate" type="date" value="<?php echo date("Y-m-d") ?>" required>
        </label>
        <label>
            <b>End Date</b> <input name="endDate" type="date" value="<?php echo isset($_SESSION['selectedED'])? $_SESSION['selectedED'] : '' ?>" required>
        </label><br>
        <p><input type="submit" value="View Available Rooms" name="roomsA" /></p>
    </form>

    <form action = "<?php echo $_SERVER['PHP_SELF'];?>" method='POST'>
		<table>
			<tr>
				<th>Room Number</th>
				<th>Start Date</th>
				<th>End Date</th>
                <th>Select </th>
			</tr>

			<?php
                //false when no results
                //$availableRooms =(getAvailableRoomsForHotel($startDate, $endDate, $hotel));

                
                if ($availableRooms != false)
                {
                    $count=0;
                foreach($availableRooms as $array)
                {
                    
                    echo '<tr>
                                        
                                        <td>'. $array['room_number'].'</td>
                                        <td>'.$startDate.'</td>
                                        <td>'.$endDate.'</td>
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
</body>
</html>