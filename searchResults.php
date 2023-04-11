<?php
    
?>
<h2>Room Search Results</h2>
<?php 
    var_dump(getSearchResults($startDate, $endDate, $area, $chain, $minCat, $maxCat, $minCap, $anyPrice?-1:$maxPrice, $anyRooms?-1:$maxRooms));
?>
