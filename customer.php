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
    $minPriceVal = $priceExtremes->min;
    $maxPriceVal = $priceExtremes->max;
    $maxCapVal = getMaxCapacity()->max;
    $roomsExtremes = getRoomsExtremes();
    $minRoomsVal = $roomsExtremes->min;
    $maxRoomsVal = $roomsExtremes->max;

    if (isset($_GET['search'])) {
        $startDate = $_GET['startDate'];
        $endDate = $_GET['endDate'];
        $area = $_GET['area'];
        $chain = $_GET['chain'];
        $minCat= $_GET['minCat'];
        $maxCat = $_GET['maxCat'];
        $minCap = $_GET['minCap'];
        $anyPrice = isset($_GET['anyPrice']) && $_GET['anyPrice']=='on';
        $maxPrice = $_GET['maxPrice'];
        $anyRooms = isset($_GET['anyRooms']) && $_GET['anyRooms']=='on';
        $maxRooms = $_GET['maxRooms'];        
    }

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
            <b>Start Date</b> <input name="startDate" type="date" <?php if(isset($startDate)) echo 'value="'.$startDate.'"' ?> required>
        </label>
        <label>
            <b>End Date</b> <input name="endDate" type="date" <?php if(isset($endDate)) echo 'value="'.$endDate.'"' ?> required>
        </label><br>

        <label>
            <b>Area</b> <select name="area" required>
                <option value="" disabled <?php echo isset($area) ? '' : 'selected' ?> hidden>Select city...</option>
                <?php
                    foreach ($view1 as $city_rooms) {
                        echo '<option value="'.$city_rooms['city'].'" '.((isset($area) && $area==$city_rooms['city']) ? 'selected' : '').'>'
                            .$city_rooms['city'].' ('.$city_rooms['count'].' total rooms available)
                        </option>';
                    }
                ?>
            </select>
        </label><br>

        <label>
            Chain <select name="chain">
                <option value="any" <?php echo (isset($chain) && $chain=='any') ? 'selected' : '' ?>>Any chain</option>
                <option value="Sugar Deluxe" <?php echo (isset($chain) && $chain=='Sugar Deluxe') ? 'selected' : '' ?>>Sugar Deluxe</option>
                <option value="Maple Inn" <?php echo (isset($chain) && $chain=='Maple Inn') ? 'selected' : '' ?>>Maple Inn</option>
                <option value="Paradise Away" <?php echo (isset($chain) && $chain=='Paradise Away') ? 'selected' : '' ?>>Paradise Away</option>
                <option value="North Vacation" <?php echo (isset($chain) && $chain=='North Vacation') ? 'selected' : '' ?>>North Vacation</option>
                <option value="Reddington Resort" <?php echo (isset($chain) && $chain=='Reddington Resort') ? 'selected' : '' ?>>Reddington Resort</option>
            </select>
        </label><br>
        Category
        <label>
            min <input name="minCat" type="number" min="1" max="5" value="<?php echo isset($minCat) ? $minCat : 1 ?>">
        </label>
        <label>
            max <input name="maxCat" type="number" min="1" max="5" value="<?php echo isset($maxCat) ? $maxCat : 5 ?>">
        </label><br>

        <label>
            Price limit ($/day) <input id="maxPrice" name="maxPrice" type="number" min="<?php echo $minPriceVal; ?>" max="<?php echo $maxPriceVal; ?>" value="<?php echo isset($maxPrice) ? $maxPrice : $minPriceVal ?>">
        </label>
        <label>
            Any price <input name="anyPrice" type="checkbox" onClick="anyPriceChanged(this)" <?php echo isset($anyPrice)&&$anyPrice ? 'checked' : '' ?>>
        </label><br>

        <label>
            Minimum room capacity <input name="minCap" type="number" min="1" max="<?php echo $maxCapVal; ?>" value="<?php echo isset($minCap) ? $minCap : 1 ?>">
        </label><br>

        <label>
            Total hotel room limit <input id="maxRooms" name="maxRooms" type="number" min="<?php echo $minRoomsVal; ?>" max="<?php echo $maxRoomsVal; ?>" value="<?php echo isset($maxRooms) ? $maxRooms : $minRoomsVal; ?>">
        </label>
        <label>
            Any amount <input name="anyRooms" type="checkbox" onClick="anyRoomsChanged(this)" <?php echo isset($anyRooms)&&$anyRooms ? 'checked' : '' ?>>
        </label><br>

        <input name="search" type="submit" value="Search rooms"><br><br><hr>

    </form>

    <?php if(isset($_GET['search'])) include 'searchResults.php'; ?>

</body>
</html>
