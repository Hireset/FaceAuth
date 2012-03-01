<?php
/*
  Example to verify client data.
  Returns bool
*/
function verifiyToken($username, $token) {
  $SECRET_KEY = 'Med1a_Cube$Even7';
  $splittedToken = split(":", $token);
  $token = $splittedToken[0];
  $timestamp = $splittedToken[1];

  $hash = sha1($username . $SECRET_KEY . $timestamp);
  $deltaTime = time() - $timestamp;

  if($deltaTime < 60 && $hash == $timestamp) {
    return true;
  }

  return false;
}
?>