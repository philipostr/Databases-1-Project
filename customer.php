<?php
    session_start();
    require_once 'db.php';

    // check if someone went straight to this page without logging in
    if (!isset($_SESSION['username']) || !isset($_SESSION['usertype']) || $_SESSION['usertype'] != 'customer') {
        header("location: {$PGVALUES['host']}/Databases-1-Project/login.php");
    }

    DBconnect();

    $user = $_SESSION['username'];
    $custinf = getSinAndName('customer', $user);
    $csin = $custinf->customer_sin;
    $name = $custinf->name;

    $view1 = getView1();
    $priceExtremes = getPriceExtremes();
    $minPrice = $priceExtremes->min;
    $maxPrice = $priceExtremes->max;
    $maxCapacity = getMaxCapacity()->max;
    $roomsExtremes = getRoomsExtremes();
    $minRooms = $roomsExtremes->min;
    $maxRooms = $roomsExtremes->max;

?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels</title>
</head>
<body>
    <h1> Alliance Hotels Customer Page</h1>
    <h2>Welcome, <?php echo $name ?> </h2>
    <p>Find available rooms (<b>bold</b> is required):</p>
    
    <form method="GET">
        <label>
            <b>Start Date</b> <input name="startDate" type="date" required>
        </label>
        <label>
            <b>End Date</b> <input name="endDate" type="date" required>
        </label><br>

        <label>
            <b>Area</b> <select name="area" required>
                <option value="" disabled selected hidden>Select city...</option>
                <?php
                    foreach ($view1 as $city_rooms) {
                        echo '<option value="'.$city_rooms['city'].'">'.$city_rooms['city'].' ('.$city_rooms['count'].' total rooms available)</option>';
                    }
                ?>
            </select>
        </label><br>

        <label>
            Chain <select name="chain">
                <option value="" disabled selected hidden>Select chain...</option>
                <option value="sugar">Sugar Deluxe</option>
                <option value="maple">Maple Inn</option>
                <option value="paradise">Paradise Away</option>
                <option value="north">North Vacation</option>
                <option value="reddington">Reddington Resort</option>
            </select>
        </label><br>
        Category
        <label>
            min <input name="mincat" type="number" min="1" max="5" value="1">
        </label>
        <label>
            max <input name="maxcat" type="number" min="1" max="5" value="5">
        </label><br>

        <label>
            Price limit ($/day) <input id="maxprice" name="maxprice" type="number" min="<?php echo $minPrice; ?>" max="<?php echo $maxPrice; ?>" value="<?php echo $minPrice; ?>">
        </label>
        <label>
            Any price <input name="anyprice" type="checkbox" onClick="anypriceChanged(this)">
        </label><br>

        <label>
            Minimum room capacity <input name="mincap" type="number" min="1" max="<?php echo $maxCapacity; ?>" value="1">
        </label><br>

        <label>
            Total hotel room limit <input id="maxrooms" name="maxrooms" type="number" min="<?php echo $minRooms; ?>" max="<?php echo $maxRooms; ?>" value="<?php echo $minRooms; ?>">
        </label>
        <label>
            Any amount <input name="anyrooms" type="checkbox" onClick="anyroomsChanged(this)">
        </label><br>

        <input type="submit" value="Search rooms">
        
    </form>

    <script>
        function anypriceChanged(anyprice) {
            let maxprice = document.getElementById('maxprice');
            if (anyprice.checked) maxprice.disabled = true;
            else maxprice.disabled = false;
        }

        function anyroomsChanged(anyrooms) {
            let maxrooms = document.getElementById('maxrooms');
            if (anyrooms.checked) maxrooms.disabled = true;
            else maxrooms.disabled = false;
        }
    </script>

</body>
</html>
