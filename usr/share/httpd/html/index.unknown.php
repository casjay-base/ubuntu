<!DOCTYPE html>
<html>
<head>
<?php include "https://static.casjay.net/casjays-header.php"; ?>
<title>Domain Doesn't Exist</title>

</head>
<body>
<br><br>
<div class="c1">
<h2>UMMMMM<br>
This site doesn't seem to exist<br>
<br><br><br><br><br>
</div>
<div class="c5">
<br>
<?php echo "Server Name: ".$_SERVER['SERVER_NAME']."<BR>";
echo "IP Address: ".$_SERVER['SERVER_ADDR']."<BR>"; ?>
<br><br>
Linux OsVer: <?php echo shell_exec('cat /etc/redhat-release'); ?><br>
ConfigVer: <?php echo shell_exec('cat /etc/casjaysdev/updates/versions/configs.txt'); ?>
<br><br>
Powered by a Redhat based system<br>
<a href="https://redhat.com"> <img border="0" alt="Redhat/CentOS/Fedora/SL Linux" src="/default-icons/powered_by_redhat.jpg"> </a><br>
<br><br><br><br><br>
</div>
<!-- Begin Casjays Developments Footer -->
<center>
<?php include "https://static.casjay.net/casjays-footer.php"; ?>
</center>
<!-- End Casjays Developments Footer -->
</body>
</html>
