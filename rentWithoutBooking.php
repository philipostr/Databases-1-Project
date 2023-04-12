<?php
    //session_start();
    require_once 'db.php';
    DBconnect();

    function dostuff(){
        echo "yasdfadf";
    }
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
    echo $csin;
    echo $hotel;
    echo "SUCCESS";

    if (isset($_POST['save'])){
        $roomNum = $_POST['roomNum'];
        $startDate = $_POST['startDate'];
        $endDate = $_POST['endDate'];
        echo $roomNum;
        echo $startDate;
        echo $endDate;
        if(createRents($csin, $roomNum, $hotel, $startDate, $endDate, "false")){
            echo "SUCCESS";
        }


    }

    //createRents($sin, $rn, $hn, $sd, $ed, $was_booked)
    
?>

<body>
    <h3>All the rents fields <?php $hotel?></h3>
    <form method="POST">
        <label>
            <b>Room Number</b> <input name="roomNum" type="number" min=1 required>
        </label>

        <label>
            <b>Start Date</b> <input name="startDate" type="date" required>
        </label>
        <label>
            <b>End Date</b> <input name="endDate" type="date" required>
        </label><br>
        <p><input type="submit" value="Rent" name="save" /></p>
    </form>
</body>
</html>