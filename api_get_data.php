<?php
header('Content-Type: application/json');
require 'db_connect.php'; // Includes session_start(), $pdo, require_login()

// Check if user is logged in and get their ID
$current_user_id = require_login(); // This will exit if not logged in

$response = ['success' => false, 'data' => null, 'message' => ''];

try {
    // Fetch user data
    $stmt = $pdo->prepare("SELECT user_id, username, points, spins_total, spins_left, slots_tokens, scratch_cards_left, last_daily_bonus_claimed
                           FROM users
                           WHERE user_id = ?");
    $stmt->execute([$current_user_id]);
    $user = $stmt->fetch(); // Default is assoc

    if ($user) {
        // Fetch recent activity (limit for dashboard)
        $stmt_activity = $pdo->prepare("SELECT activity_type, description, points_change, timestamp
                                        FROM activity_log
                                        WHERE user_id = ?
                                        ORDER BY timestamp DESC
                                        LIMIT 10"); // Limit for dashboard view
        $stmt_activity->execute([$current_user_id]);
        $user['activity'] = $stmt_activity->fetchAll(); // Default is assoc

        // Check daily bonus eligibility
        $today = date('Y-m-d');
        $user['can_claim_bonus'] = ($user['last_daily_bonus_claimed'] === null || $user['last_daily_bonus_claimed'] < $today);

        $response['success'] = true;
        $response['data'] = $user;
    } else {
        // This case should ideally not happen if require_login() worked, but good practice
        $response['message'] = 'User data not found.';
        http_response_code(404);
    }

} catch (PDOException $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'Database error fetching data.';
    http_response_code(500);
} catch (Exception $e) {
    // Log error $e->getMessage() in production
    $response['message'] = 'An unexpected error occurred.';
    http_response_code(500);
}

echo json_encode($response);
?>