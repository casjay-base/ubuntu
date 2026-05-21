<?php
error_reporting(E_ALL | E_NOTICE);
$locale = 'en_US.UTF-8';
$language = 'en';
date_default_timezone_set("America/New_York");
$iface_list = array('mynetworkdevice');
$iface_title['mynetworkdevice'] = ' External';
$vnstat_bin = '/usr/bin/vnstat';
$data_dir = './dumps';
$graph_format = 'png';
$byte_notation = null;
define('GRAPH_FONT', dirname(__FILE__) . '/VeraBd.ttf');
define('SVG_FONT', 'Verdana');
define('DEFAULT_COLORSCHEME', 'casjaysdev');
define('SVG_DEPTH_SCALING', 1);

?>
