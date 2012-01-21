<?php require_once "inc/header.php"; ?>

<div id="message"></div>

<h3>Facedetection:</h3>

<label for="userId">Username:</label>
<input type="text" size="40" id="userId">

<label for="imageUrl">Image-Url:</label>
<input type="text" size="40" id="imageUrl">

<p>
<input type="button" value=" Add face " id="addButton" class="submit">
<input type="button" value=" Recognize face " id="recButton" class="submit">
</p>

<?php require_once "inc/footer.php"; ?>