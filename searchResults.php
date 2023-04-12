<?php
    $results = getSearchResults($startDate, $endDate, $area, $chain, $minCat, $maxCat, $minCap, $anyPrice?-1:$maxPrice, $anyRooms?-1:$maxRooms);

    echo '<h2>Room Search Results</h2>';

    if ($results) {
        echo '
            <table>
                <tr>
                    <th>Chain</th>
                    <th>Name</th>
                    <th>Address</th>
                    <th>Room number</th>
                    <th>Capacity</th>
                    <th>Price ($/day)</th>
                    <th>Extra Info</th>
                </tr>
        ';

        $row = 0;
        foreach ($results as $room) {
            $row++;
            $colour = $row%2==1 ? 'w' : 'g';

            echo '
            <tr>
                <td class="'.$colour.'">'.$room['chain_name'].'</td>
                <td class="'.$colour.'">'.$room['hotel_name'].'</td>
                <td class="'.$colour.'">'.$room['address'].'</td>
                <td class="'.$colour.'">'.$room['room_number'].'</td>
                <td class="'.$colour.'">'.$room['capacity'].'</td>
                <td class="'.$colour.'">'.$room['price'].'</td>
                <td class="'.$colour.'">
                    <table>
                        <tr><td class="info-name">Amenities:</td> <td class="info">'.$room['amenities'].'</td></tr>
                        <tr><td class="info-name">View:</td> <td class="info">'.$room['view'].'</td></tr>
                        <tr><td class="info-name">Extendable:</td> <td class="info">'.$room['extendable'].'</td></tr>
                        <tr><td class="info-name">Problems:</td> <td class="info">'.$room['problems'].'</td></tr>
                    </table>
                </td>
                <td>
                    <form method="post" target="submitBooking" action="submitBooking.php">
                        <input class="invisible" name="csin" type="text" value="'.$csin.'">
                        <input class="invisible" name="hn" type="text" value="'.$room['hotel_name'].'">
                        <input class="invisible" name="rn" type="text" value="'.$room['room_number'].'">
                        <input class="invisible" name="sd" type="text" value="'.$startDate.'">
                        <input class="invisible" name="ed" type="text" value="'.$endDate.'">
                        <input type="submit" value="Book" onClick="disableSubmit(this)">
                    </form>
                </td>
            </tr>
            ';
        }

        echo '</table>';
    } else {
        echo '
            <p>No rooms were found using these filters</p>
        ';
    }
?>

<iframe class="invisible" name="submitBooking"></iframe>

<style>
    td,th {
        padding-left: 10px;
        padding-right: 10px;
        text-align: center;
    }
    .info {
        padding-left: 0px;
        padding-right: 0px;
        padding-bottom: 10px;
        text-align: left;
        max-width: 250px;
    }
    .info-name {
        padding-left: 0px;
        padding-right: 10px;
        padding-bottom: 10px;
        text-align: right;
    }
    .w {
        background-color: #e4e4e4;
    }
    .g {
        background-color: #bbbbbb;
    }
    .invisible {
        display: none;
    }
</style>

<script>
    function disableSubmit(submit) {
        setTimeout(() => {  submit.disabled = true; }, 100);
    }
</script>