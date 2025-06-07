<?php
header('Content-Type: application/json');
require 'db_connect.php'; // Includes session_start(), $pdo, require_login()

// Check login and get user ID
$current_user_id = require_login(); // This will exit if not logged in

$response = [
    'success' => false,
    'message' => '',
    'prize_won' => 0,       // Can be positive or negative now
    'new_points' => 0,
    'spins_left' => 0,
    'winning_segment_index' => 0 // Index (0-based) of the winning segment
];

try {
    $pdo->beginTransaction(); // Start transaction for data consistency

    // 1. Check if user has spins left and get current points
    $stmt = $pdo->prepare("SELECT spins_left, points FROM users WHERE user_id = ? FOR UPDATE"); // Lock the user row
    $stmt->execute([$current_user_id]);
    $user = $stmt->fetch(); // Use default fetch mode (assoc)

    if (!$user) {
        // This should technically not happen if require_login works, but safety check
        throw new Exception("User data error during spin.", 404);
    }

    if ($user['spins_left'] <= 0) {
        $response['message'] = 'No spins left!';
        $response['spins_left'] = 0;
        $pdo->rollBack(); // No changes needed
        echo json_encode($response);
        exit;
    }

    // 2. Define Wheel Segments and Prizes - MUST MATCH FRONTEND JS ORDER/PRIZES
    $segments = [
        // Must match the order and prize values in index.html's spinWheelSegments JS array
        ['prize' => 10,  'label' => '10'],   // Index 0
        ['prize' => 50,  'label' => '50'],   // Index 1
        ['prize' => 10, 'label' => '10'],   // Index 2
        ['prize' => 10,  'label' => '10'],   // Index 3
        ['prize' => 100, 'label' => '100'],   // Index 4
        ['prize' => 75,  'label' => '75'],   // Index 5
        ['prize' => 20, 'label' => '20'],   // Index 6
        ['prize' => 25, 'label' => '25'],   // Index 7
        ['prize' => 5,   'label' => '5'],    // Index 8
        
         // If you implement "Take 50 Points", you'd need a special prize value/type
         // e.g., ['prize' => 0, 'label' => 'Take 50!', 'type' => 'special_action']
    ];
    $num_segments = count($segments); // Should be 12

    // 3. Determine Winning Segment (Simple Random Selection)
    // For more control over probabilities, you could create a weighted array
    $winning_index = rand(0, $num_segments - 1);
    $prize_details = $segments[$winning_index];
    $prize_won = $prize_details['prize']; // This can be positive or negative
    $prize_label = $prize_details['label'];
    // $prize_type = $prize_details['type'] ?? 'standard'; // Example if adding special types

    // Handle special prize types if necessary (e.g., "Take 50 Points") - Not implemented here

    // 4. Update User Data
    $new_spins_left = $user['spins_left'] - 1;
    $new_points = $user['points'] + $prize_won; // Add or subtract points based on prize_won

    // Ensure points don't go below zero (or apply other game rules)
    if ($new_points < 0) {
        $new_points = 0;
    }

    $update_stmt = $pdo->prepare("UPDATE users SET points = ?, spins_left = ?, last_spin_time = NOW() WHERE user_id = ?");
    $update_stmt->execute([$new_points, $new_spins_left, $current_user_id]);

    // 5. Log Activity
    $log_type = ($prize_won > 0) ? 'spin_win' : (($prize_won < 0) ? 'spin_loss' : 'spin_neutral'); // Handle negative prizes
    if ($prize_won > 0) {
        $log_desc = "Won {$prize_won} Points from Spin Wheel ({$prize_label})";
    } elseif ($prize_won < 0) {
         $log_desc = "Lost {$prize_won} Points from Spin Wheel ({$prize_label})"; // Prize is already negative
    } else {
         $log_desc = "Spin Wheel result: {$prize_label} (No points change)";
    }

    $log_stmt = $pdo->prepare("INSERT INTO activity_log (user_id, activity_type, description, points_change) VALUES (?, ?, ?, ?)");
    $log_stmt->execute([$current_user_id, $log_type, $log_desc, $prize_won]);

    // 6. Commit Transaction
    $pdo->commit();

    // 7. Prepare Success Response
    if ($prize_won > 0) {
        $response['message'] = "You won {$prize_won} points!";
    } elseif ($prize_won < 0) {
         $response['message'] = "You lost ". abs($prize_won) ." points!"; // Show positive value for loss amount
    } else {
         $response['message'] = "Landed on {$prize_label}. No points change.";
    }
    $response['success'] = true;
    $response['prize_won'] = $prize_won; // Send the actual prize value (can be negative)
    $response['new_points'] = $new_points;
    $response['spins_left'] = $new_spins_left;
    $response['winning_segment_index'] = $winning_index; // Send index to JS for animation

} catch (PDOException $e) {
    $pdo->rollBack(); // Rollback on database error
    $response['message'] = 'Database error during spin. Please try again later.'; // User-friendly message
    http_response_code(500);
    // Log the actual error $e->getMessage() on the server
} catch (Exception $e) {
    if ($pdo->inTransaction()) { // Check if still in transaction before rollback
        $pdo->rollBack();
    }
    $response['message'] = 'An error occurred: ' . $e->getMessage(); // Provide error message
    http_response_code(isset($e->code) && is_int($e->code) ? $e->code : 500); // Set appropriate HTTP status
    // Log the actual error $e->getMessage() on the server
}

echo json_encode($response);
?>