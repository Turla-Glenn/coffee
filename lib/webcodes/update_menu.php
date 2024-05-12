<?php
include 'db_connection.php';

$id = $_POST['id'];
$name = $_POST['name'];
$description = $_POST['description'];
$price = $_POST['price'];

// Check if a new image file is uploaded
if(isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $image = $_FILES['image'];

    $targetDir = "uploads/";
    $targetFile = $targetDir . basename($image["name"]);

    // Move the uploaded file to the target directory
    if (move_uploaded_file($image["tmp_name"], $targetFile)) {
        $imageUrl = $targetFile;

        // Update menu item with the new image
        $sql = "UPDATE menu SET name='$name', description='$description', price=$price, image='$imageUrl' WHERE id=$id";

        if ($conn->query($sql) === TRUE) {
            echo "Record updated successfully";
        } else {
            echo "Error updating record: " . $conn->error;
        }
    } else {
        // If there was an error moving the file, return an error message
        http_response_code(500);
        echo "Sorry, there was an error uploading your file.";
    }
} else {
    // Update menu item without changing the image
    $sql = "UPDATE menu SET name='$name', description='$description', price=$price WHERE id=$id";

    if ($conn->query($sql) === TRUE) {
        echo "Record updated successfully";
    } else {
        echo "Error updating record: " . $conn->error;
    }
}

$conn->close();
?>
