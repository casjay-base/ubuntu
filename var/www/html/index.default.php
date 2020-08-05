<!DOCTYPE html>
<html>
<head>
<?php include "https://casjaysdev-sites.github.io/static.casjay.net/casjays-header.php"; ?>
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
Linux OsVer: <?php echo shell_exec('cat /etc/debian_version'); ?>  <br>
ConfigVer: <?php echo shell_exec('echo $(cat /etc/casjaysdev/updates/versions/raspbian.txt | tail -n 1)'); ?><br><br><br>
Powered by a Debian Based Distro<br>
<a href="https://debian.org"> <img border="0" alt="Debian/Ubuntu/Raspbian" src="https://casjaysdev-sites.github.io/static.casjay.net/default-icons/powered_by_debian.jpg"></a><br><br><br><br>
  </div>

<center>
<!-- Begin Casjays Developments Footer -->
<?php include "https://casjaysdev-sites.github.io/static.casjay.net/casjays-footer.php"; ?>
</center>
<!-- End Casjays Developments Footer -->
</body>
</html>
