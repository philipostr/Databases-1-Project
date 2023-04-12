<?php
    include 'db.php';
    DBconnect();

    createBooks($_POST['csin'], $_POST['rn'], $_POST['hn'], $_POST['sd'], $_POST['ed']);
?>
