<?php
include 'db_connection.php';

$id = $_POST['id'];

$sql = "DELETE FROM menu WHERE id=$id";

if ($conn->query($sql) === TRUE) {
    echo "Record deleted successfully";
} else {
    echo "Error deleting record: " . $conn->error;
}

$conn->close();
?>
