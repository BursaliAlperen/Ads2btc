<?php
require 'functions.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_POST['user_id'];
    $amount = floatval($_POST['amount']);

    $user = getUserById($userId);
    if ($user) {
        $newBalance = $user['balance'] + $amount;
        if (updateUserBalance($userId, $newBalance)) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false]);
        }
    } else {
        echo json_encode(['success' => false]);
    }
}
?>
