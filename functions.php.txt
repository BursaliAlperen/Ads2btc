<?php
require 'config.php';

function getUserById($userId) {
    global $pdo;
    $stmt = $pdo->prepare("SELECT * FROM users WHERE user_id = ?");
    $stmt->execute([$userId]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

function createUser($userId, $firstName, $lastName, $username) {
    global $pdo;
    $stmt = $pdo->prepare("INSERT INTO users (user_id, first_name, last_name, username) VALUES (?, ?, ?, ?)");
    return $stmt->execute([$userId, $firstName, $lastName, $username]);
}

function updateUserBalance($userId, $balance) {
    global $pdo;
    $stmt = $pdo->prepare("UPDATE users SET balance = ? WHERE user_id = ?");
    return $stmt->execute([$balance, $userId]);
}

function banUser($userId, $reason) {
    global $pdo;
    $stmt = $pdo->prepare("UPDATE users SET is_banned = TRUE, ban_reason = ? WHERE user_id = ?");
    return $stmt->execute([$reason, $userId]);
}

function unbanUser($userId) {
    global $pdo;
    $stmt = $pdo->prepare("UPDATE users SET is_banned = FALSE, ban_reason = NULL WHERE user_id = ?");
    return $stmt->execute([$userId]);
}

function getAllUsers() {
    global $pdo;
    $stmt = $pdo->query("SELECT * FROM users");
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>
