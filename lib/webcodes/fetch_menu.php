<?php
include 'db_connection.php';

$sql = "SELECT * FROM menu";
$result = $conn->query($sql);
$menu = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $image_url = isset($row['image']) ? 'http://192.168.100.155/flutter/' . $row['image'] : ''; // Check if 'image' key exists
        $row['image_url'] = $image_url;
        $menu[] = $row;
    }
    echo json_encode($menu);
} else {
    echo "0 results";
}

$conn->close();
?>
