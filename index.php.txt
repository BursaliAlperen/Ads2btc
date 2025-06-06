<?php
require 'functions.php';

// Check if the admin parameter is set
if (isset($_GET['admin']) && $_GET['admin'] == '7316439041') { // your admin id
    header("Location: admin.php");
    exit;
}

// Check if user ID is provided in the URL
if (isset($_GET['id'])) {
    $userId = $_GET['id'];
    $user = getUserById($userId);

    if (!$user) {
        // Create a new user if not exists
        createUser($userId, 'Guest', 'User', '');
        $user = getUserById($userId);
    }

    // Ensure numeric values are properly initialized
    $balance = isset($user['balance']) ? (float)$user['balance'] : 0.00;
    $today_earnings = isset($user['today_earnings']) ? (float)$user['today_earnings'] : 0.00;
    $total_earnings = isset($user['total_earnings']) ? (float)$user['total_earnings'] : 0.00;

    // Check if the user is banned
    if ($user['is_banned']) {
        // Show modern banned message with icon
        die('
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Account Banned</title>
            <link href="https://fonts.googleapis.com/css2?family=Google+Sans:wght@400;500;700&display=swap" rel="stylesheet">
            <script src="https://unpkg.com/lucide@latest"></script>
            <script src="https://cdn.tailwindcss.com"></script>
            <style>
                body {
                    font-family: "Google Sans", sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    background-color: #f3f4f6;
                }
            </style>
        </head>
        <body>
            <div class="text-center p-6 max-w-md mx-auto">
                <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i data-lucide="ban" class="w-10 h-10 text-red-600"></i>
                </div>
                <h2 class="text-2xl font-bold text-red-600 mb-2">Account Banned</h2>
                <p class="text-gray-600 mb-4">Your account has been suspended by the administrator.</p>
                <p class="text-sm text-gray-500">Please contact support if you believe this is a mistake.</p>
            </div>
            <script>lucide.createIcons();</script>
        </body>
        </html>');
    }
} else {
    die("User ID is required.");
}

// Set cookie name based on user ID to track completed ads
$cookieName = 'ads_completed_' . $userId;
$completedAds = isset($_COOKIE[$cookieName]) ? json_decode($_COOKIE[$cookieName], true) : ['count' => 0, 'last_completed' => null];
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Watch Ad & Earn Money</title>
    <link href="https://fonts.googleapis.com/css2?family=Google+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
    <style>
        body {
            font-family: 'Google Sans', sans-serif;
            -webkit-tap-highlight-color: transparent;
        }

        .nav-btn.active {
            position: relative;
        }

        .nav-btn.active::before {
            content: '';
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 3px;
            background: #2563eb;
            border-radius: 3px;
        }

        .popup {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 90%;
            animation: popIn 0.3s ease-out;
        }

        @keyframes popIn {
            0% { transform: translate(-50%, -50%) scale(0.8); opacity: 0; }
            100% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
        }

        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }

        .pinned-message {
            background-color: #f8f9fa;
            border-left: 4px solid #2563eb;
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 0 8px 8px 0;
            font-size: 14px;
        }

        .countdown-timer {
            font-family: monospace;
            font-weight: bold;
            color: #2563eb;
        }

        .ad-container {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Popup Modal -->
    <div id="popup-modal" class="popup hidden">
        <div class="flex justify-center mb-4">
            <div id="popup-icon" class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
                <i data-lucide="info" class="w-8 h-8 text-blue-600"></i>
            </div>
        </div>
        <h3 id="popup-title" class="text-lg font-bold mb-2">Info</h3>
        <p id="popup-message" class="text-gray-600 mb-4">Message goes here</p>
        <button id="close-popup" class="bg-blue-600 text-white px-6 py-2 rounded-lg">OK</button>
    </div>

    <div class="overlay hidden"></div>

    <!-- Main App Content -->
    <div id="app-content" class="max-w-md mx-auto min-h-screen flex flex-col pb-16 bg-white relative">
        <!-- Header -->
        <header class="bg-blue-600 text-white p-4 shadow-md">
            <div class="flex justify-between items-center">
                <h1 class="text-xl font-bold">Earn Money</h1>
                <button id="user-btn" class="p-2 rounded-full">
                    <i data-lucide="user" class="w-5 h-5"></i>
                </button>
            </div>
        </header>

        <!-- Main Content -->
        <main class="flex-1 p-4 overflow-y-auto">
            <!-- Pinned Message -->
            <div class="pinned-message">
                <i data-lucide="alert-triangle" class="w-4 h-4 inline mr-1 text-yellow-600"></i>
                <strong>Note:</strong> This is a test bot and doesn't provide actual rewards. You can create your own real bot like this.
            </div>

            <!-- Home Page Content -->
            <div id="home-page">
                <div class="bg-white rounded-lg shadow-md p-6 mb-4">
                    <div class="flex items-center mb-4">
                        <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                            <i data-lucide="user" class="text-blue-600 w-8 h-8"></i>
                        </div>
                        <div>
                            <h2 id="user-name" class="text-lg font-semibold">Loading...</h2>
                            <p id="user-id" class="text-gray-500">ID: <?php echo htmlspecialchars($user['user_id']); ?></p>
                        </div>
                    </div>

                    <div class="bg-blue-50 rounded-lg p-4 mb-4">
                        <div class="flex justify-between items-center">
                            <div>
                                <p class="text-gray-500 text-sm">Available Balance</p>
                                <p id="user-balance" class="text-2xl font-bold">$<?php echo number_format($balance, 2); ?></p>
                            </div>
                            <button id="withdraw-btn" class="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center">
                                <i data-lucide="banknote" class="w-4 h-4 mr-1"></i> Withdraw
                            </button>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4 mb-4">
                        <div class="bg-green-50 p-3 rounded-lg">
                            <p class="text-gray-500 text-sm">Today Earnings</p>
                            <p id="today-earnings" class="text-lg font-semibold">$<?php echo number_format($today_earnings, 2); ?></p>
                        </div>
                        <div class="bg-purple-50 p-3 rounded-lg">
                            <p class="text-gray-500 text-sm">Total Earnings</p>
                            <p id="total-earnings" class="text-lg font-semibold">$<?php echo number_format($total_earnings, 2); ?></p>
                        </div>
                    </div>

                    <div class="mb-4">
                        <h3 class="font-semibold mb-2">Quick Actions</h3>
                        <div class="grid grid-cols-3 gap-2">
                            <button id="watch-ad-btn" class="bg-gray-100 p-3 rounded-lg flex flex-col items-center">
                                <i data-lucide="play" class="w-6 h-6 text-blue-600 mb-1"></i>
                                <span class="text-xs">Watch Ads</span>
                            </button>
                            <button class="bg-gray-100 p-3 rounded-lg flex flex-col items-center">
                                <i data-lucide="users" class="w-6 h-6 text-green-600 mb-1"></i>
                                <span class="text-xs">Refer Friends</span>
                            </button>
                            <button class="bg-gray-100 p-3 rounded-lg flex flex-col items-center">
                                <i data-lucide="gift" class="w-6 h-6 text-purple-600 mb-1"></i>
                                <span class="text-xs">Rewards</span>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-md p-4">
                    <h3 class="font-semibold mb-3">Available Ads (<span id="remaining-ads"><?php echo max(0, 3 - $completedAds['count']); ?></span>/3)</h3>
                    <div class="space-y-3" id="ads-container">
                        <!-- Ads will be loaded here -->
                    </div>
                    <p class="text-sm text-gray-500 mt-2">Next ads in: <span id="next-ads-time" class="countdown-timer">00:00:00</span></p>
                </div>
            </div>

            <!-- Other Pages (Hidden by default) -->
            <div id="ads-page" class="hidden">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <h2 class="text-lg font-semibold mb-4">Available Ads (<span id="remaining-ads-page"><?php echo max(0, 3 - $completedAds['count']); ?></span>/3)</h2>
                    <div id="ads-page-container" class="space-y-3">
                        <!-- Ads will be loaded here -->
                    </div>
                    <p class="text-sm text-gray-500 mt-2">Next ads in: <span id="next-ads-time-page" class="countdown-timer">00:00:00</span></p>
                </div>
            </div>

            <div id="friends-page" class="hidden">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <div class="text-center py-10">
                        <i data-lucide="construction" class="w-12 h-12 mx-auto text-gray-400 mb-3"></i>
                        <h3 class="text-lg font-semibold mb-2">Coming Soon</h3>
                        <p class="text-gray-500">The Friends feature will be available in the next update!</p>
                    </div>
                </div>
            </div>

            <div id="withdraw-page" class="hidden">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <h2 class="text-lg font-semibold mb-4">Withdraw Earnings</h2>
                    <div class="space-y-4">
                        <div class="border border-gray-200 rounded-lg p-4">
                            <h3 class="font-medium mb-2">Payment Methods</h3>
                            <div class="space-y-3">
                                <label class="flex items-center p-2 bg-gray-50 rounded-lg cursor-pointer">
                                    <input type="radio" name="payment-method" value="bank" class="mr-3" checked>
                                    <i data-lucide="credit-card" class="w-5 h-5 text-blue-600 mr-3"></i>
                                    <span>Bank Transfer</span>
                                </label>
                                <label class="flex items-center p-2 bg-gray-50 rounded-lg cursor-pointer">
                                    <input type="radio" name="payment-method" value="mobile" class="mr-3">
                                    <i data-lucide="smartphone" class="w-5 h-5 text-green-600 mr-3"></i>
                                    <span>Mobile Money</span>
                                </label>
                                <label class="flex items-center p-2 bg-gray-50 rounded-lg cursor-pointer">
                                    <input type="radio" name="payment-method" value="paypal" class="mr-3">
                                    <i data-lucide="dollar-sign" class="w-5 h-5 text-purple-600 mr-3"></i>
                                    <span>PayPal</span>
                                </label>
                            </div>
                        </div>

                        <div class="border border-gray-200 rounded-lg p-4">
                            <h3 class="font-medium mb-2">Withdrawal Details</h3>
                            <div class="space-y-3">
                                <div>
                                    <label class="text-sm text-gray-500">Amount ($)</label>
                                    <input type="number" id="withdraw-amount" class="w-full p-2 border border-gray-300 rounded-lg mt-1" placeholder="1.00" min="1" step="0.01">
                                </div>
                                <div>
                                    <label class="text-sm text-gray-500">Account Details</label>
                                    <input type="text" id="account-details" class="w-full p-2 border border-gray-300 rounded-lg mt-1" placeholder="Enter your account details">
                                </div>
                                <button id="request-withdraw-btn" class="bg-blue-600 text-white w-full py-2 rounded-lg mt-2">
                                    Request Withdrawal
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="account-page" class="hidden">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <h2 class="text-lg font-semibold mb-4">My Account</h2>
                    <div class="space-y-4">
                        <div class="flex items-center p-3 border border-gray-200 rounded-lg">
                            <i data-lucide="user" class="w-5 h-5 text-gray-500 mr-3"></i>
                            <span>Profile Settings</span>
                        </div>
                        <div class="flex items-center p-3 border border-gray-200 rounded-lg">
                            <i data-lucide="shield" class="w-5 h-5 text-gray-500 mr-3"></i>
                            <span>Security</span>
                        </div>
                        <div class="flex items-center p-3 border border-gray-200 rounded-lg">
                            <i data-lucide="help-circle" class="w-5 h-5 text-gray-500 mr-3"></i>
                            <span>Help & Support</span>
                        </div>
                        <div class="flex items-center p-3 border border-gray-200 rounded-lg">
                            <i data-lucide="log-out" class="w-5 h-5 text-gray-500 mr-3"></i>
                            <span>Logout</span>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Bottom Navigation -->
        <nav class="fixed bottom-0 left-0 right-0 bg-white shadow-lg border-t border-gray-200 max-w-md mx-auto">
            <div class="flex justify-around py-2">
                <button class="nav-btn active w-full py-2 flex flex-col items-center" data-page="home-page">
                    <i data-lucide="home" class="w-5 h-5"></i>
                    <span class="text-xs mt-1">Home</span>
                </button>
                <button class="nav-btn w-full py-2 flex flex-col items-center" data-page="ads-page">
                    <i data-lucide="video" class="w-5 h-5"></i>
                    <span class="text-xs mt-1">Ads</span>
                </button>
                <button class="nav-btn w-full py-2 flex flex-col items-center" data-page="friends-page">
                    <i data-lucide="users" class="w-5 h-5"></i>
                    <span class="text-xs mt-1">Friends</span>
                </button>
                <button class="nav-btn w-full py-2 flex flex-col items-center" data-page="withdraw-page">
                    <i data-lucide="banknote" class="w-5 h-5"></i>
                    <span class="text-xs mt-1">Withdraw</span>
                </button>
                <button class="nav-btn w-full py-2 flex flex-col items-center" data-page="account-page">
                    <i data-lucide="user" class="w-5 h-5"></i>
                    <span class="text-xs mt-1">Account</span>
                </button>
            </div>
        </nav>
    </div>

    <!-- Include the Monet Tag Ad Script -->
    <script src='//libtl.com/sdk.js' data-zone='9394302' data-sdk='show_9394302'></script>

    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        // Navigation logic
        document.querySelectorAll('.nav-btn').forEach(button => {
            button.addEventListener('click', function() {
                // Remove active class from all buttons
                document.querySelectorAll('.nav-btn').forEach(btn => {
                    btn.classList.remove('active');
                });

                // Add active class to clicked button
                this.classList.add('active');

                // Hide all pages
                document.querySelectorAll('main > div').forEach(page => {
                    page.classList.add('hidden');
                });

                // Show the selected page
                const pageId = this.getAttribute('data-page');
                const page = document.getElementById(pageId);

                // Block withdraw page if balance is less than $1
                if (pageId === 'withdraw-page' && parseFloat(document.getElementById('user-balance').textContent.replace('$', '')) < 1) {
                    showPopup('Info', 'This page will be automatically unlocked once you reach $1.');
                    // Keep the current active button
                    this.classList.remove('active');
                    document.querySelector('.nav-btn[data-page="home-page"]').classList.add('active');
                    document.getElementById('home-page').classList.remove('hidden');
                    return;
                }

                page.classList.remove('hidden');
            });
        });

        // Popup logic
        function showPopup(title, message, type = 'info') {
            const icon = document.getElementById('popup-icon');
            icon.className = 'w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4';

            // Set icon based on type
            if (type === 'success') {
                icon.classList.add('bg-green-100');
                icon.innerHTML = '<i data-lucide="check-circle" class="w-8 h-8 text-green-600"></i>';
            } else if (type === 'error') {
                icon.classList.add('bg-red-100');
                icon.innerHTML = '<i data-lucide="alert-circle" class="w-8 h-8 text-red-600"></i>';
            } else {
                icon.classList.add('bg-blue-100');
                icon.innerHTML = '<i data-lucide="info" class="w-8 h-8 text-blue-600"></i>';
            }

            document.getElementById('popup-title').textContent = title;
            document.getElementById('popup-message').textContent = message;
            document.getElementById('popup-modal').classList.remove('hidden');
            document.querySelector('.overlay').classList.remove('hidden');

            // Reinitialize Lucide icons for the new icon
            lucide.createIcons();
        }

        document.getElementById('close-popup').addEventListener('click', function() {
            document.getElementById('popup-modal').classList.add('hidden');
            document.querySelector('.overlay').classList.add('hidden');
        });

        // Cookie functions
        function getCookie(name) {
            const value = `; ${document.cookie}`;
            const parts = value.split(`; ${name}=`);
            if (parts.length === 2) return parts.pop().split(';').shift();
            return null;
        }

        function setCookie(name, value, days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            const expires = `expires=${date.toUTCString()}`;
            document.cookie = `${name}=${value}; ${expires}; path=/`;
        }

        // Get completed ads from cookie or initialize
        function getCompletedAds() {
            const cookieName = 'ads_completed_<?php echo $userId; ?>';
            const cookieValue = getCookie(cookieName);
            if (cookieValue) {
                return JSON.parse(cookieValue);
            }
            return { count: 0, last_completed: null };
        }

        // Update completed ads in cookie
        function updateCompletedAds(count, lastCompleted) {
            const cookieName = 'ads_completed_<?php echo $userId; ?>';
            const data = {
                count: count,
                last_completed: lastCompleted
            };
            setCookie(cookieName, JSON.stringify(data), 30); // Store for 30 days
        }

        // Ad watching logic
        function watchAd(button) {
            const adContainer = button.closest('.ad-container');

            button.disabled = true;
            button.innerHTML = '<i data-lucide="loader-2" class="w-4 h-4 animate-spin mx-auto"></i> Loading...';
            lucide.createIcons();

            show_9394302().then(() => {
                fetch('update_balance.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `user_id=<?php echo $userId; ?>&amount=0.01`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Remove the ad container
                        adContainer.remove();

                        // Get current completed ads
                        const completedAds = getCompletedAds();
                        const newCount = completedAds.count + 1;
                        const now = new Date().toISOString();

                        // Update completed ads in cookie
                        updateCompletedAds(newCount, now);

                        // Update remaining ads count
                        const remainingAds = Math.max(0, 3 - newCount);
                        document.getElementById('remaining-ads').textContent = remainingAds;
                        document.getElementById('remaining-ads-page').textContent = remainingAds;

                        // Update balance display
                        const newBalance = parseFloat(document.getElementById('user-balance').textContent.replace('$', '')) + 0.01;
                        const newTodayEarnings = parseFloat(document.getElementById('today-earnings').textContent.replace('$', '')) + 0.01;
                        const newTotalEarnings = parseFloat(document.getElementById('total-earnings').textContent.replace('$', '')) + 0.01;

                        document.getElementById('user-balance').textContent = '$' + newBalance.toFixed(2);
                        document.getElementById('today-earnings').textContent = '$' + newTodayEarnings.toFixed(2);
                        document.getElementById('total-earnings').textContent = '$' + newTotalEarnings.toFixed(2);

                        // Start countdown if all ads watched
                        if (remainingAds === 0) {
                            startCountdown();
                        }

                        updateQuickActionButtons();
                        loadAds(); // Reload ads to ensure both sections are updated
                        showPopup('Success', 'You earned $0.01!', 'success');
                    } else {
                        showPopup('Error', data.message || 'Failed to update balance.', 'error');
                        button.disabled = false;
                        button.innerHTML = 'Watch';
                    }
                });
            }).catch((error) => {
                console.log('Ad error:', error);
                showPopup('Error', 'Ad failed to load or was skipped. Please try again.', 'error');
                button.disabled = false;
                button.innerHTML = 'Watch';
            });
        }

        // Load ads
        function loadAds() {
            const adsContainer = document.getElementById('ads-container');
            const adsPageContainer = document.getElementById('ads-page-container');

            // Clear existing ads
            adsContainer.innerHTML = '';
            adsPageContainer.innerHTML = '';

            // Get completed ads from cookie
            const completedAds = getCompletedAds();
            const remainingAds = Math.max(0, 3 - completedAds.count);

            if (remainingAds > 0) {
                for (let i = 0; i < remainingAds; i++) {
                    const adHtml = `
                        <div class="ad-container flex items-center p-3 border border-gray-200 rounded-lg">
                            <div class="bg-blue-100 p-2 rounded-lg mr-3">
                                <i data-lucide="video" class="w-5 h-5 text-blue-600"></i>
                            </div>
                            <div class="flex-1">
                                <h4 class="font-medium">Video Ad ${i+1} (30 sec)</h4>
                                <p class="text-sm text-gray-500">Earn $0.01</p>
                            </div>
                            <button onclick="watchAd(this)" class="watch-ad-btn bg-blue-600 text-white px-3 py-1 rounded-lg text-sm">
                                Watch
                            </button>
                        </div>
                    `;
                    adsContainer.innerHTML += adHtml;
                    adsPageContainer.innerHTML += adHtml;
                }
            } else {
                const noAdsHtml = `
                    <div class="text-center py-10">
                        <i data-lucide="clock" class="w-12 h-12 mx-auto text-gray-400 mb-3"></i>
                        <p class="text-gray-500">You've watched all available ads. Come back later!</p>
                    </div>
                `;
                adsContainer.innerHTML = noAdsHtml;
                adsPageContainer.innerHTML = noAdsHtml;

                // Start countdown if all ads watched
                startCountdown();
            }

            // Reinitialize Lucide icons for new elements
            lucide.createIcons();
            updateQuickActionButtons();
        }

        // Countdown timer for ad refresh
        function startCountdown() {
            const completedAds = getCompletedAds();
            const lastCompletedTime = completedAds.last_completed ? new Date(completedAds.last_completed) : new Date();
            const resetHours = 24;
            const nextAdTime = new Date(lastCompletedTime);
            nextAdTime.setHours(nextAdTime.getHours() + resetHours);

            function updateTimer() {
                const now = new Date();
                const diff = nextAdTime - now;

                if (diff <= 0) {
                    // Reset ads count and reload
                    updateCompletedAds(0, null);
                    loadAds();
                    return;
                }

                // Calculate hours, minutes, seconds
                const hours = Math.floor(diff / (1000 * 60 * 60));
                const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((diff % (1000 * 60)) / 1000);

                // Format as HH:MM:SS
                const timeString = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

                document.getElementById('next-ads-time').textContent = timeString;
                document.getElementById('next-ads-time-page').textContent = timeString;

                // Continue updating every second
                setTimeout(updateTimer, 1000);
            }

            // Start the countdown
            updateTimer();
        }

        // Load ads initially
        loadAds();

        // Check if we need to start countdown on page load
        const completedAds = getCompletedAds();
        if (completedAds.count >= 3) {
            startCountdown();
        }

        // Update quick action buttons
        function updateQuickActionButtons() {
            const watchAdBtn = document.getElementById('watch-ad-btn');
            const completedAds = getCompletedAds();
            const remainingAds = Math.max(0, 3 - completedAds.count);

            if (remainingAds === 0) {
                watchAdBtn.innerHTML = '<i data-lucide="play" class="w-6 h-6 text-gray-400 mb-1"></i><span class="text-xs">Not working</span>';
            } else {
                watchAdBtn.innerHTML = '<i data-lucide="play" class="w-6 h-6 text-blue-600 mb-1"></i><span class="text-xs">Watch Ads</span>';
            }
        }

        // Telegram WebApp user details
        if (window.Telegram && Telegram.WebApp.initDataUnsafe && Telegram.WebApp.initDataUnsafe.user) {
            const user = Telegram.WebApp.initDataUnsafe.user;
            document.getElementById('user-name').textContent = user.first_name ? user.first_name + (user.last_name ? ' ' + user.last_name : '') : 'Guest User';
            console.log("User ID:", user.id);
            console.log("First Name:", user.first_name);
            console.log("Last Name:", user.last_name);
            console.log("Username:", user.username);
        }

        // Withdraw button handler
        document.getElementById('request-withdraw-btn').addEventListener('click', function() {
            const amount = parseFloat(document.getElementById('withdraw-amount').value);
            const accountDetails = document.getElementById('account-details').value.trim();
            const paymentMethod = document.querySelector('input[name="payment-method"]:checked').value;

            if (!amount || isNaN(amount) || amount < 1) {
                showPopup('Error', 'Minimum withdrawal amount is $1.00', 'error');
                return;
            }

            if (amount > parseFloat(document.getElementById('user-balance').textContent.replace('$', ''))) {
                showPopup('Error', 'Insufficient balance for this withdrawal', 'error');
                return;
            }

            if (!accountDetails) {
                showPopup('Error', 'Please enter your account details', 'error');
                return;
            }

            // Submit withdrawal request
            fetch('process_withdrawal.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `user_id=<?php echo $userId; ?>&amount=${amount}&method=${paymentMethod}&account_details=${encodeURIComponent(accountDetails)}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showPopup('Success', 'Withdrawal request submitted successfully!', 'success');
                    // Update balance display
                    document.getElementById('user-balance').textContent = '$' + parseFloat(data.new_balance).toFixed(2);
                    // Clear form
                    document.getElementById('withdraw-amount').value = '';
                    document.getElementById('account-details').value = '';
                } else {
                    showPopup('Error', data.message || 'Failed to process withdrawal', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showPopup('Error', 'An error occurred while processing your request', 'error');
            });
        });

        // Function to update user name
        function updateUserName() {
            if (window.Telegram && Telegram.WebApp.initDataUnsafe && Telegram.WebApp.initDataUnsafe.user) {
                const user = Telegram.WebApp.initDataUnsafe.user;
                const userNameElement = document.getElementById('user-name');
                userNameElement.textContent = user.first_name ? user.first_name + (user.last_name ? ' ' + user.last_name : '') : 'Guest User';
            }
        }

        // Call the function to update user name when the page loads
        document.addEventListener('DOMContentLoaded', function() {
            updateUserName();
        });

    </script>
</body>
</html>
