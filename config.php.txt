<?php
$host = 'sql100.hstn.me';
$dbname = 'mseet_38992593_db';
$username = 'mseet_38992593';
$password = 'RrC4xNSiL0uI';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Could not connect to the database: " . $e->getMessage());
}
?>
