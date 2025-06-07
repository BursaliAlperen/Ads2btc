<?php
// Start session management - MUST be called before any output
if (session_status() == PHP_SESSION_NONE) {
    // Consider adding session security settings here in production
    // session_set_cookie_params(['lifetime' => 0, 'path' => '/', 'domain' => '.yourdomain.com', 'secure' => true, 'httponly' => true, 'samesite' => 'Lax']);
    session_start();
}

// --- Database Configuration ---
define('DB_HOST', 'localhost'); // Or your DB host (e.g., 127.0.0.1)
define('DB_NAME', 'spin_earn_db');
define('DB_USER', 'root');      // CHANGE if needed
define('DB_PASS', '');          // CHANGE if needed

// --- Establish Connection ---
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC); // Optional: Default fetch mode
} catch (PDOException $e) {
    // Generic error for API responses
    header('Content-Type: application/json');
    http_response_code(500);
    // Log the detailed error $e->getMessage() to a server file in production
    die(json_encode(['success' => false, 'message' => 'Database connection error. Please contact support.']));
}

// --- Helper function to check login status ---
function require_login() {
    if (!isset($_SESSION['user_id'])) {
        header('Content-Type: application/json');
        http_response_code(401); // Unauthorized
        die(json_encode(['success' => false, 'message' => 'Authentication required. Please login.', 'action' => 'login_required']));
    }
    return $_SESSION['user_id']; // Return the user ID if logged in
}

// Note: No hardcoded user ID anymore. APIs will call require_login().
?>