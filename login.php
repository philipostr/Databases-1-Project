<?php
    session_start();

    require_once 'db.php';
    DBconnect();

    if(isset($_POST['logout'])) {
        session_unset();
    }

    if (isset($_POST['login'])) {
        $usertype = $_POST['usertype'];
        $username = $_POST['username'];
        $password = $_POST['password'];

        if (checkLogin($usertype, $username, $password)) {
            $_SESSION['usertype'] = $usertype;
            $_SESSION['username'] = $username;
    
            if ($usertype === 'customer') {
                header("location: {$PGVALUES['host']}/Databases-1-Project/customer.php");
            } else {
                header("location: {$PGVALUES['host']}/Databases-1-Project/employee.php");
            }
            exit;
        } else {
            $problem = "User not found in the database";

        }
    }
?>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alliance Hotels Login</title>
</head>
<body>
    <h1>Welcome to Alliance Hotels!</h1>
    <form method="post">
        <label>
            <input name="usertype" type="radio" value="customer" <?php if(isset($usertype)) {if ($usertype=='customer') echo 'checked';} else {echo 'checked';}  ?>>
            Customer
        </label>
        <label>
            <input name="usertype" type="radio" value="employee" <?php if(isset($usertype) && $usertype=='employee') echo 'checked' ?>>
            Employee
        </label><br>

        <label>Username: 
            <input name="username" type="text" placeholder="Username123" value="<?php echo isset($username) ? $username : ''; ?>" required>
        </label><br>
        <label>Password: 
            <input name="password" type="text" placeholder="Password321" value="<?php echo isset($password) ? $password : ''; ?>" required>
        </label><br>
        
        <input name="login" type="submit" value="Login">
        <p><?php echo isset($problem) ? $problem : '' ?></p>
    </form>
</body>
</html>
