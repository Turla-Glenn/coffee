<?php
include 'db_connection.php';

// Check if all required fields are set
if (isset($_POST['name']) && isset($_POST['description']) && isset($_POST['price']) && isset($_FILES['image'])) {
    $name = $_POST['name'];
    $description = $_POST['description'];
    $price = $_POST['price'];
    $image = $_FILES['image'];

    // Check for file upload errors
    if ($image['error'] == UPLOAD_ERR_OK) {
        $targetDir = "uploads/";
        $targetFile = $targetDir . basename($image["name"]);

        // Move the uploaded file to the target directory
        if (move_uploaded_file($image["tmp_name"], $targetFile)) {
            $imageUrl = $targetFile;

            // Insert menu item into the database
            $sql = "INSERT INTO menu (name, description, price, image) VALUES ('$name', '$description', $price, '$imageUrl')";

            if ($conn->query($sql) === TRUE) {
                // If insertion was successful, return success message
                echo "New record created successfully";
            } else {
                // If there was an error with the SQL query, return an error message
                http_response_code(500);
                echo "Error: " . $sql . "<br>" . $conn->error;
            }
        } else {
            // If there was an error moving the file, return an error message
            http_response_code(500);
            echo "Sorry, there was an error uploading your file.";
        }
    } else {
        // If no file was uploaded or there was an error, return an error message
        http_response_code(400);
        echo "No image uploaded or there was an error.";
    }
} else {
    // If required fields are not set, return a bad request error
    http_response_code(400);
    echo "Missing required fields.";
}

// Close database connection
$conn->close();
?>
