<?php

chdir('/srv/mediawiki');

require_once '/etc/phpsh/rc.php';
require_once '/srv/mediawiki/index.php';

define('DEFAULT_IO_FILE', getenv('HOME').'/o');

/**
 * Append array or var to ~/o.
 * @author dcorson
 */
function o($x, $fn=DEFAULT_IO_FILE) {
  $f = fopen($fn, 'a');
  if (is_array($x)) {
    fwrite($f, implode("\n", $x)."\n");
  } else {
    fwrite($f, $x."\n");
  }
  fclose($f);
  return true;
}

/**
 * Strip last char (typically used to kill "\n") from line.
 * @author dcorson
 */
function _rstrip($l) {
  return substr($l, 0, strlen($l) - 1);
}

/**
 * Read array from ~/o.
 * @author dcorson
 */
function i($fn=DEFAULT_IO_FILE) {
  return array_map('_rstrip', file($fn));
}

