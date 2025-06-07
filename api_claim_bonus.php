<?php
header('Content-Type: application/json');
require 'db_connect.php';

// Check login and get user ID
$current_user_id = require_login();

$response = [ /* keep structure */
    'success' => false, 'message' => '', 'bonus_amount' => 0, 'new_points' => 0
];
$daily_bonus_amount = 25;

try {
    $pdo->beginTransaction();

    // 1. Check last claimed
    $stmt = $pdo->prepare("SELECT points, last_daily_bonus_claimed FROM users WHERE user_id = ? FOR UPDATE");
    $stmt->execute([$current_user_id]);
    $user = $stmt->fetch();

    if (!$user) throw new Exception("User data error.", 404);

    $today = date('Y-m-d');
    if ($user['last_daily_bonus_claimed'] !== null && $user['last_daily_bonus_claimed'] >= $today) {
        $response['message'] = 'Bonus already claimed today!';
        $response['new_points'] = $user['points'];
        $pdo->rollBack(); echo json_encode($response); exit;
    }

    // 2. Award Bonus
    $new_points = $user['points'] + $daily_bonus_amount;
    $update_stmt = $pdo->prepare("UPDATE users SET points = ?, last_daily_bonus_claimed = ? WHERE user_id = ?");
    $update_stmt->execute([$new_points, $today, $current_user_id]);

    // 3. Log
    $log_desc = "Claimed Daily Bonus ({$daily_bonus_amount} Pts)";
    $log_stmt = $pdo->prepare("INSERT INTO activity_log (user_id, activity_type, description, points_change) VALUES (?, ?, ?, ?)");
    $log_stmt->execute([$current_user_id, 'bonus_claim', $log_desc, $daily_bonus_amount]);

    // 4. Commit
    $pdo->commit();

    // 5. Response
    $response['success'] = true;
    $response['message'] = "Bonus of {$daily_bonus_amount} points claimed!";
    $response['bonus_amount'] = $daily_bonus_amount;
    $response['new_points'] = $new_points;

} catch (PDOException $e) { $pdo->rollBack(); $response['message'] = 'DB error.'; http_response_code(500); /* Log */ }
  catch (Exception $e) { if ($pdo->inTransaction()) $pdo->rollBack(); $response['message'] = $e->getMessage(); http_response_code(isset($e->code) ? $e->code : 500); /* Log */ }

echo json_encode($response);
?>