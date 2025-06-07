<?php
header('Content-Type: application/json');
require 'db_connect.php'; // Includes session_start() and $pdo

$response = ['success' => false, 'message' => ''];

// Get input data from POST request body (assuming JSON)
$input = json_decode(file_get_contents('php://input'), true);

$username = $input['username'] ?? null;
$password = $input['password'] ?? null;
$confirmPassword = $input['confirmPassword'] ?? null;

// --- Basic Input Validation ---
if (empty($username) || strlen($username) < 3 || strlen($username) > 50) {
    $response['message'] = 'Username must be between 3 and 50 characters.';
    echo json_encode($response);
    exit;
}
if (!preg_match('/^[a-zA-Z0-9_]+$/', $username)) {
     $response['message'] = 'Username can only contain letters, numbers, and underscores.';
     echo json_encode($response);
     exit;
}
if (empty($password) || strlen($password) < 6) {
    $response['message'] = 'Password must be at least 6 characters long.';
    echo json_encode($response);
    exit;
}
if ($password !== $confirmPassword) {
    $response['message'] = 'Passwords do not match.';
    echo json_encode($response);
    exit;
}

try {
    // --- Check if username already exists ---
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        $response['message'] = 'Username already taken. Please choose another.';
        echo json_encode($response);
        exit;
    }

    // --- Hash the password ---
    // IMPORTANT: Use a strong hashing algorithm like BCRYPT (default for password_hash)
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    if ($password_hash === false) {
         throw new Exception("Password hashing failed."); // Should not happen usually
    }


    // --- Insert new user into database ---
    $insert_stmt = $pdo->prepare("INSERT INTO users (username, password_hash, spins_left, slots_tokens, scratch_cards_left) VALUES (?, ?, ?, ?, ?)");
    // Give default resources on registration
    $default_spins = 5;
    $default_tokens = 10;
    $default_scratch = 3;
    $insert_stmt->execute([$username, $password_hash, $default_spins, $default_tokens, $default_scratch]);

    $new_user_id = $pdo->lastInsertId();

    // --- Automatically log the user in after registration ---
    session_regenerate_id(true); // Prevent session fixation
    $_SESSION['user_id'] = $new_user_id;
    $_SESSION['username'] = $username;

    $response['success'] = true;
    $response['message'] = 'Registration successful! You are now logged in.';
    // Optionally send back user data if needed by frontend immediately
    // $response['user'] = ['user_id' => $new_user_id, 'username' => $username];

} catch (PDOException $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'Database error during registration. Please try again.';
    http_response_code(500);
} catch (Exception $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'An error occurred: ' . $e->getMessage();
    http_response_code(500);
}

echo json_encode($response);
?>