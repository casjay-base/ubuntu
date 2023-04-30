<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="/default-css/casjaysdev.css">
<meta name="generator" content="CasjaysDev">
<title>Site Configured</title>
</head>
<body>
<br><br>

  <div class="c1">
<h2>Welcome to your new site  <br>
The site you have visited has  <br>
just been setup and the user  <br>
hasn't created a site yet. <br><br>
Please come back soon as I'm sure the <br>
site owner is working on it!  <br><br><br><br>
  </div>

  <div class="c3">
Server Admin you can now upload your site to  <br>
<?php echo $_SERVER['DOCUMENT_ROOT']; ?>  <br><br><br>
<?php echo "Server Name: ".$_SERVER['SERVER_NAME']."<BR>"; ?>
<?php echo "IP Address: ".$_SERVER['SERVER_ADDR']."<BR>"; ?>  <br>
Linux OsVer: <?php echo shell_exec('cat /etc/redhat-release'); ?>  <br>
ConfigVer: <?php echo shell_exec('cat /etc/casjaysdev/updates/versions/configs.txt'); ?><br><br><br>
Powered by a Redhat based system<br>
<a href="https://redhat.com"> <img border="0" alt="Redhat/CentOS/Fedora/SL Linux" src="/default-icons/powered_by_redhat.jpg"> </a><br><br><br><br>
  </div>

<center>
<!-- Begin Casjays Developments Footer -->
<?php include "https://casjaysdev-sites.github.io/static/casjays-footer.php"; ?>
</center>
<!-- End Casjays Developments Footer -->
</body>
</html>
