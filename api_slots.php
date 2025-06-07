<?php
header('Content-Type: application/json');
require 'db_connect.php';

// Check login and get user ID
$current_user_id = require_login();

$response = [
    'success' => false,
    'message' => '',
    'reels' => [],
    'win_amount' => 0,
    'new_tokens' => 0,
    'new_points' => 0,
];

// Game Configuration (Keep as before or adjust)
$slot_cost_tokens = 1;
$symbols = ['🍒', '🍋', '🍊', '🍉', '⭐', '🔔', '７'];
$reels_count = 3;
$payouts = [ /* ... keep payouts ... */
    '🍒' => [2 => 2, 3 => 5],
    '🍋' => [3 => 10], '🍊' => [3 => 15], '🍉' => [3 => 25],
    '⭐' => [3 => 50], '🔔' => [3 => 75], '７' => [3 => 100],
];
$winning_line_index = 1;

try {
    $pdo->beginTransaction();

    // 1. Check tokens
    $stmt = $pdo->prepare("SELECT slots_tokens, points FROM users WHERE user_id = ? FOR UPDATE");
    $stmt->execute([$current_user_id]);
    $user = $stmt->fetch();

    if (!$user) throw new Exception("User data error.", 404);

    if ($user['slots_tokens'] < $slot_cost_tokens) {
        $response['message'] = 'Not enough tokens!';
        $response['new_tokens'] = $user['slots_tokens'];
        $response['new_points'] = $user['points'];
        $pdo->rollBack(); echo json_encode($response); exit;
    }

    // 2. Deduct Cost
    $new_tokens = $user['slots_tokens'] - $slot_cost_tokens;
    $new_points = $user['points'];

    // 3. Spin Reels
    $final_reels = [];
    for ($i = 0; $i < $reels_count; $i++) {
        $final_reels[$i] = $symbols[array_rand($symbols)];
    }

    // 4. Check Wins (Keep logic as before)
    $win_amount_multiplier = 0;
    $winning_symbol = $final_reels[0];
    $is_win = true;
    for ($i = 1; $i < $reels_count; $i++) { if ($final_reels[$i] !== $winning_symbol) { $is_win = false; break; } }
    if (!$is_win && $winning_symbol === '🍒') { /* ... cherry check ... */
        $cherry_count = 0; foreach($final_reels as $symbol) { if ($symbol === '🍒') $cherry_count++; }
        if ($cherry_count >= 2 && isset($payouts['🍒'][$cherry_count])) { $win_amount_multiplier = $payouts['🍒'][$cherry_count]; $is_win = true; }
    } else if ($is_win && isset($payouts[$winning_symbol][$reels_count])) { $win_amount_multiplier = $payouts[$winning_symbol][$reels_count]; }

    $win_amount_points = 0;
    if ($win_amount_multiplier > 0) { $win_amount_points = $win_amount_multiplier * 5; $new_points += $win_amount_points; }

    // 5. Update User Data
    $update_stmt = $pdo->prepare("UPDATE users SET slots_tokens = ?, points = ? WHERE user_id = ?");
    $update_stmt->execute([$new_tokens, $new_points, $current_user_id]);

    // 6. Log Activity
    $log_desc = ($win_amount_points > 0) ? "Slot Machine win: " . implode(" ", $final_reels) . " ({$win_amount_points} Pts)" : "Slot Machine result: " . implode(" ", $final_reels);
    $log_type = ($win_amount_points > 0) ? 'slot_win' : 'slot_loss';
    $log_stmt = $pdo->prepare("INSERT INTO activity_log (user_id, activity_type, description, points_change) VALUES (?, ?, ?, ?)");
    $log_stmt->execute([$current_user_id, $log_type, $log_desc, $win_amount_points]);

    // 7. Commit
    $pdo->commit();

    // 8. Response
    $response['success'] = true;
    $response['message'] = ($win_amount_points > 0) ? "You won {$win_amount_points} points!" : "No win this time.";
    $response['reels'] = $final_reels;
    $response['win_amount'] = $win_amount_points;
    $response['new_tokens'] = $new_tokens;
    $response['new_points'] = $new_points;

} catch (PDOException $e) { $pdo->rollBack(); $response['message'] = 'DB error.'; http_response_code(500); /* Log */ }
  catch (Exception $e) { if ($pdo->inTransaction()) $pdo->rollBack(); $response['message'] = $e->getMessage(); http_response_code(isset($e->code) ? $e->code : 500); /* Log */ }

echo json_encode($response);
?>