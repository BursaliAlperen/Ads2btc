<?php
header('Content-Type: application/json');
require 'db_connect.php'; // Includes session_start() and $pdo

$response = ['success' => false, 'message' => ''];

// Get input data from POST request body (assuming JSON)
$input = json_decode(file_get_contents('php://input'), true);

$username = $input['username'] ?? null;
$password = $input['password'] ?? null;

// Basic validation
if (empty($username) || empty($password)) {
    $response['message'] = 'Username and password are required.';
    echo json_encode($response);
    exit;
}

try {
    // --- Find user by username ---
    $stmt = $pdo->prepare("SELECT user_id, username, password_hash FROM users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(); // Use default fetch mode (assoc)

    if (!$user) {
        $response['message'] = 'Invalid username or password.'; // Generic message for security
        echo json_encode($response);
        exit;
    }

    // --- Verify the password ---
    // IMPORTANT: Use password_verify() which compares against the stored hash
    if (password_verify($password, $user['password_hash'])) {
        // Password is correct

        // --- Regenerate session ID for security ---
        session_regenerate_id(true);

        // --- Store user info in session ---
        $_SESSION['user_id'] = $user['user_id'];
        $_SESSION['username'] = $user['username'];

        $response['success'] = true;
        $response['message'] = 'Login successful!';
        // Optionally send back user data if needed by frontend immediately
        // $response['user'] = ['user_id' => $user['user_id'], 'username' => $user['username']];

    } else {
        // Password is incorrect
        $response['message'] = 'Invalid username or password.'; // Generic message
    }

} catch (PDOException $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'Database error during login. Please try again.';
    http_response_code(500);
} catch (Exception $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'An error occurred during login.';
    http_response_code(500);
}

echo json_encode($response);
?>