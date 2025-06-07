<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spin & Earn - App</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* --- Base CSS Variables & Resets --- */
        :root {
            --primary-color: #007bff; /* ... other color vars */
            --primary-light: #cce5ff; --primary-dark: #0056b3; --secondary-color: #6c757d;
            --secondary-light: #e2e3e5; --secondary-dark: #5a6268; --accent-color: #ffc107;
            --accent-light: #fff3cd; --accent-dark: #e0a800; --success-color: #28a745;
            --success-light: #d4edda; --success-dark: #1e7e34; --danger-color: #dc3545;
            --danger-light: #f8d7da; --danger-dark: #b02a37; --warning-color: #ffc107;
            --warning-light: #fff3cd; --warning-dark: #e0a800; --info-color: #17a2b8;
            --info-light: #d1ecf1; --info-dark: #117a8b; --purple-color: #6f42c1;
            --purple-light: #e2d9f3; --purple-dark: #5a32a3; --light-color: #f8f9fa;
            --dark-color: #343a40; --white-color: #ffffff; --black-color: #000000;
            --background-color: #f4f7fc; --surface-color: var(--white-color); --text-primary: #212529;
            --text-secondary: #6c757d; --text-light: var(--white-color); --border-color: #dee2e6;
            --shadow-color: rgba(0, 0, 0, 0.1); --sidebar-width: 240px; --header-height: 60px;
            --border-radius: 8px; --transition-speed: 0.3s; --shadow-sm: 0 1px 3px var(--shadow-color);
            --shadow-md: 0 4px 6px var(--shadow-color); --shadow-lg: 0 10px 15px var(--shadow-color);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body { font-family: 'Inter', sans-serif; font-size: 15px; line-height: 1.6; background-color: var(--background-color); color: var(--text-primary); display: flex; min-height: 100vh; overflow-x: hidden; }
        /* --- Base Element Styles (Keep from previous) --- */
        h1, h2, h3, h4 { font-weight: 600; line-height: 1.3; margin-bottom: 0.75em; }
        h1 { font-size: 1.6rem; } h2 { font-size: 1.4rem; color: var(--primary-dark); } h3 { font-size: 1.2rem; color: var(--dark-color); } h4 { font-size: 1rem; color: var(--secondary-dark); margin-bottom: 0.5em;}
        p { margin-bottom: 1em; color: var(--text-secondary); }
        a { color: var(--primary-color); text-decoration: none; transition: color var(--transition-speed) ease; } a:hover { color: var(--primary-dark); text-decoration: underline; }
        ul { list-style: none; }
        button { font-family: inherit; font-size: inherit; cursor: pointer; border: none; border-radius: var(--border-radius); padding: 0.6em 1.2em; transition: background-color var(--transition-speed) ease, box-shadow var(--transition-speed) ease; }
        button:disabled { cursor: not-allowed; opacity: 0.65; } button:focus { outline: 2px solid var(--primary-light); outline-offset: 2px; }
        img { max-width: 100%; height: auto; display: block; }
        i.fas, i.fab, i.far { vertical-align: middle; margin-right: 0.5em; } button i.fas, button i.fab, button i.far { margin-right: 0.3em; }

        /* --- Layout (Header, Sidebar, Main, Overlay - Keep from previous) --- */
        .dashboard-container { display: flex; flex-direction: column; width: 100%; min-height: 100vh; }
        .header { position: fixed; top: 0; left: 0; width: 100%; height: var(--header-height); background-color: var(--white-color); color: var(--primary-color); display: flex; align-items: center; justify-content: space-between; padding: 0 15px; box-shadow: var(--shadow-sm); z-index: 1000; }
        #menu-toggle { background: none; border: none; color: var(--primary-color); font-size: 1.5rem; cursor: pointer; padding: 5px; display: block; }
        .logo { font-size: 1.5rem; font-weight: 700; margin: 0; color: var(--primary-color); text-align: center; position: absolute; left: 50%; transform: translateX(-50%); }
        .user-profile-icon { font-size: 1.6rem; color: var(--secondary-color); display: flex; align-items: center; } .user-profile-icon i { margin: 0; } .user-profile-icon span { display: none; font-size: 0.9rem; margin-left: 8px; color: var(--text-secondary); }
        .sidebar { position: fixed; top: 0; left: calc(-1 * var(--sidebar-width)); width: var(--sidebar-width); height: 100%; background-color: var(--dark-color); color: var(--light-color); padding-top: calc(var(--header-height) + 15px); padding-bottom: 20px; z-index: 999; transition: left var(--transition-speed) ease-in-out; overflow-y: auto; scrollbar-width: thin; scrollbar-color: var(--secondary-color) var(--dark-color); }
        .sidebar::-webkit-scrollbar { width: 6px; } .sidebar::-webkit-scrollbar-track { background: var(--dark-color); } .sidebar::-webkit-scrollbar-thumb { background-color: var(--secondary-color); border-radius: 3px; }
        .sidebar.open { left: 0; box-shadow: var(--shadow-lg); }
        .sidebar-nav ul { padding: 0; }
        .sidebar-nav li a { display: flex; align-items: center; padding: 12px 20px; color: var(--light-color); font-size: 0.95rem; font-weight: 500; border-left: 4px solid transparent; transition: background-color var(--transition-speed) ease, border-left-color var(--transition-speed) ease; }
        .sidebar-nav li a i { font-size: 1.1em; width: 25px; text-align: center; margin-right: 15px; color: var(--secondary-light); }
        .sidebar-nav li a:hover { background-color: rgba(255, 255, 255, 0.1); text-decoration: none; }
        .sidebar-nav li.active a { background-color: rgba(0, 123, 255, 0.2); border-left-color: var(--primary-color); color: var(--white-color); font-weight: 600; } .sidebar-nav li.active a i { color: var(--primary-color); }
        /* Hide/Show sidebar items based on login state */
        body.logged-out .sidebar-nav li:not(.nav-auth-link) { display: none; }
        body:not(.logged-out) .sidebar-nav li.nav-auth-link { display: none; }
        body.logged-out .sidebar-nav li.nav-logout-link { display: none; }
        body:not(.logged-out) .sidebar-nav li.nav-login-link,
        body:not(.logged-out) .sidebar-nav li.nav-register-link { display: none; }

        .overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 998; transition: opacity var(--transition-speed) ease; } .overlay.active { display: block; }
        .main-content { width: 100%; margin-left: 0; padding: calc(var(--header-height) + 20px) 15px 20px 15px; transition: margin-left var(--transition-speed) ease-in-out; flex-grow: 1; background-color: var(--background-color); }

        /* --- Page Content Styling --- */
        .page-content { display: none; animation: fadeIn 0.5s ease-in-out; }
        .page-content.active-page { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* --- Auth Form Styles (Keep from previous) --- */
        .auth-page { max-width: 400px; margin: 40px auto; padding: 30px; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-md); }
        .auth-page h2 { text-align: center; margin-bottom: 25px; color: var(--primary-dark); }
        .form-group { margin-bottom: 20px; } .form-group label { display: block; margin-bottom: 5px; font-weight: 500; color: var(--text-secondary); }
        .form-group input[type="text"], .form-group input[type="password"], .form-group input[type="email"], .form-group input[type="number"], .form-group select { width: 100%; padding: 10px 12px; border: 1px solid var(--border-color); border-radius: var(--border-radius); font-size: 1rem; transition: border-color 0.2s ease; }
        .form-group input:focus { border-color: var(--primary-color); outline: none; box-shadow: 0 0 0 2px var(--primary-light); }
        .auth-button { width: 100%; padding: 12px; font-size: 1.1rem; font-weight: 600; background-color: var(--primary-color); color: var(--white-color); border-radius: var(--border-radius); margin-top: 10px; }
        .auth-button:hover { background-color: var(--primary-dark); }
        .auth-switch-link { display: block; text-align: center; margin-top: 20px; font-size: 0.95rem; }
        .error-message { color: var(--danger-dark); background-color: var(--danger-light); border: 1px solid var(--danger-color); padding: 10px; border-radius: var(--border-radius); margin-bottom: 15px; font-size: 0.9rem; text-align: center; }
        .success-message { color: var(--success-dark); background-color: var(--success-light); border: 1px solid var(--success-color); padding: 10px; border-radius: var(--border-radius); margin-bottom: 15px; font-size: 0.9rem; text-align: center;}

        /* --- Component Styles (Dashboard Section, Stats, Features, Activity Log - Keep from previous) --- */
        .dashboard-section { background-color: var(--surface-color); padding: 20px; border-radius: var(--border-radius); box-shadow: var(--shadow-sm); margin-bottom: 20px; }
        .welcome-section h2 { margin-bottom: 0.2em; } .welcome-section p { margin-bottom: 0; font-size: 0.95rem; }
        .stats-panel { display: grid; gap: 15px; grid-template-columns: 1fr; background-color: transparent; padding: 0; box-shadow: none; margin-bottom: 20px; }
        .stat-card { display: flex; align-items: center; background-color: var(--surface-color); padding: 15px; border-radius: var(--border-radius); box-shadow: var(--shadow-sm); }
        .stat-card .icon { font-size: 1.5rem; color: var(--white-color); width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; flex-shrink: 0; }
        .stat-card .icon.bg-accent { background-color: var(--accent-color); } .stat-card .icon.bg-primary { background-color: var(--primary-color); } .stat-card .icon.bg-danger { background-color: var(--danger-color); } .stat-card .icon.bg-warning { background-color: var(--warning-color); }
        .stat-card .icon i { margin: 0; } .stat-info { display: flex; flex-direction: column; } .stat-info .label { font-size: 0.85rem; color: var(--text-secondary); text-transform: uppercase; font-weight: 500; margin-bottom: 2px; } .stat-info .value { font-size: 1.3rem; font-weight: 600; color: var(--text-primary); }
        .spin-action-section { text-align: center; } .spin-action-section h3 { color: var(--primary-dark); }
        .action-button, .spin-button, .feature-button { display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-weight: 600; border-radius: 50px; padding: 12px 25px; font-size: 1.1rem; margin: 10px 5px; }
        .spin-button { background-color: var(--primary-color); color: var(--white-color); box-shadow: 0 4px 10px rgba(0, 123, 255, 0.3); width: 100%; max-width: 300px; }
        .spin-button:hover { background-color: var(--primary-dark); box-shadow: 0 6px 12px rgba(0, 86, 179, 0.4); text-decoration: none; } .spin-button:active { transform: translateY(1px); box-shadow: 0 2px 5px rgba(0, 86, 179, 0.3); }
        .spin-timer { font-size: 0.9rem; color: var(--secondary-dark); margin-bottom: 0; } .spin-timer #spin-timer-value { font-weight: 600; color: var(--primary-color); }
        .feature-grid { display: grid; gap: 15px; grid-template-columns: 1fr; background-color: transparent; padding: 0; box-shadow: none; margin-bottom: 20px; }
        .feature-card { background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); padding: 20px; display: flex; flex-direction: column; align-items: flex-start; text-align: left; transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; overflow: hidden; } .feature-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
        .feature-header { display: flex; align-items: center; margin-bottom: 15px; width: 100%; } .feature-icon { width: 40px; height: 40px; border-radius: var(--border-radius); display: flex; align-items: center; justify-content: center; color: var(--white-color); font-size: 1.2rem; margin-right: 15px; flex-shrink: 0; } .feature-icon i { margin: 0; }
        .feature-card.daily-bonus .feature-icon { background-color: var(--success-color); } .feature-card.slots .feature-icon { background-color: var(--danger-color); } .feature-card.scratch .feature-icon { background-color: var(--warning-color); } .feature-card.refer .feature-icon { background-color: var(--purple-color); }
        .feature-card h4 { margin-bottom: 5px; font-size: 1.1rem; flex-grow: 1; } .feature-card p { font-size: 0.9rem; margin-bottom: 15px; flex-grow: 1; }
        .feature-button { font-size: 0.9rem; font-weight: 500; padding: 8px 15px; margin-top: auto; align-self: flex-start; border-radius: var(--border-radius); /* override pill shape */ }
        .feature-card.daily-bonus .feature-button { background-color: var(--success-color); color: var(--white-color); } .feature-card.slots .feature-button { background-color: var(--danger-color); color: var(--white-color); } .feature-card.scratch .feature-button { background-color: var(--warning-color); color: var(--dark-color); } .feature-card.refer .feature-button { background-color: var(--purple-color); color: var(--white-color); }
        .feature-button:hover { opacity: 0.9; text-decoration: none; } .feature-button.claimed { background-color: var(--secondary-light); color: var(--secondary-dark); cursor: not-allowed; opacity: 0.7; } .feature-button.claimed:hover { opacity: 0.7; }
        .activity-log h3, #history-content h2 { margin-bottom: 15px; }
        .activity-list { padding: 0; margin: 0; } .activity-list li { display: flex; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--border-color); font-size: 0.9rem; } .activity-list li:last-child { border-bottom: none; }
        .activity-icon { width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; font-size: 0.9rem; color: var(--white-color); flex-shrink: 0; } .activity-icon i { margin: 0; }
        .activity-icon.win, .activity-icon.spin_win, .activity-icon.slot_win, .activity-icon.scratch_win { background-color: var(--success-color); } .activity-icon.bonus, .activity-icon.bonus_claim { background-color: var(--primary-color); } .activity-icon.slot, .activity-icon.slot_loss { background-color: var(--danger-color); } .activity-icon.referral { background-color: var(--purple-color); } .activity-icon.scratch, .activity-icon.scratch_loss { background-color: var(--warning-color); color: var(--dark-color); } .activity-icon.redeem, .activity-icon.withdrawal_request { background-color: var(--accent-color); color: var(--dark-color); } .activity-icon.fail, .activity-icon.spin_loss { background-color: var(--secondary-color); }
        .activity-description { flex-grow: 1; margin-right: 10px; color: var(--text-primary); } .activity-description strong { font-weight: 600; }
        .activity-time { font-size: 0.8rem; color: var(--text-secondary); white-space: nowrap; flex-shrink: 0; }
        .view-all-activity { display: block; text-align: center; margin-top: 15px; font-weight: 500; font-size: 0.95rem; }

        /* --- Placeholder Page Styles (Used for some pages) --- */
        .placeholder-page { padding: 30px 20px; text-align: center; min-height: 300px; display: flex; flex-direction: column; align-items: center; justify-content: center; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); }
        .placeholder-page h2 { color: var(--primary-color); margin-bottom: 15px; } .placeholder-page p { color: var(--text-secondary); max-width: 400px; margin-bottom: 25px; } .placeholder-page i.page-icon { font-size: 3rem; color: var(--primary-light); margin-bottom: 20px; }
        .placeholder-page .action-button { background-color: var(--primary-color); color: var(--white-color); padding: 10px 20px; } .placeholder-page .action-button:hover { background-color: var(--primary-dark); }

        /* --- Spin Wheel Styles --- */
        .spin-wheel-container { display: flex; flex-direction: column; align-items: center; padding: 20px; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); margin-bottom: 20px; position: relative; }
        .spin-wheel-graphic { position: relative; width: 280px; height: 280px; margin-bottom: 20px; }
        .wheel { width: 100%; height: 100%; border-radius: 50%; border: 8px solid var(--primary-dark); background-color: var(--secondary-light); position: relative; overflow: hidden; transition: transform 5s cubic-bezier(0.25, 0.1, 0.25, 1); transform: rotate(0deg); }
        .wheel-segment {
            position: absolute; top: 0; left: 50%; width: 50%; height: 50%;
            transform-origin: 0% 100%; clip-path: polygon(0% 0%, 100% 0%, 50% 100%);
            display: flex; align-items: flex-start; justify-content: center;
            padding-top: 10px;
            font-size: 0.9rem; /* Slightly larger text */
            font-weight: 600; text-align: center;
            /* Color set by JS */
        }
        .wheel-segment span {
            display: block;
            transform: rotate(90deg) translateY(-18px) translateX(-50%); /* Adjust vertical position */
            transform-origin: center center; white-space: nowrap;
            text-shadow: 0 0 2px rgba(0,0,0,0.4); /* Add shadow for visibility */
        }
        .wheel-pointer { position: absolute; top: -15px; left: 50%; transform: translateX(-50%); width: 0; height: 0; border-left: 15px solid transparent; border-right: 15px solid transparent; border-top: 25px solid var(--danger-color); z-index: 10; }
        #spin-result { margin-top: 15px; font-size: 1.1rem; font-weight: bold; color: var(--primary-dark); min-height: 1.5em; }
        #spin-action-button { background-color: var(--success-color); } #spin-action-button:hover { background-color: var(--success-dark); }

        /* --- Slot Machine Styles (Keep from previous) --- */
        .slots-container { display: flex; flex-direction: column; align-items: center; padding: 20px; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); margin-bottom: 20px; }
        .slots-reels { display: flex; justify-content: center; gap: 10px; margin-bottom: 20px; padding: 15px; background: linear-gradient(180deg, #eee, #fff, #eee); border: 5px solid var(--secondary-dark); border-radius: var(--border-radius); overflow: hidden; width: fit-content; }
        .reel { width: 60px; height: 180px; background-color: var(--white-color); border: 1px solid var(--border-color); overflow: hidden; position: relative; }
        .reel-symbols { position: absolute; top: 0; left: 0; width: 100%; transition: top 0.5s cubic-bezier(0.77, 0, 0.175, 1); }
        .reel-symbol { height: 60px; font-size: 2.5rem; display: flex; align-items: center; justify-content: center; border-bottom: 1px dashed var(--border-color); }
        #slots-result { margin-top: 15px; font-size: 1.1rem; font-weight: bold; color: var(--primary-dark); min-height: 1.5em; }
        #slots-play-button { background-color: var(--danger-color); } #slots-play-button:hover { background-color: var(--danger-dark); }
        .slot-info { font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 10px; }

        /* --- Scratch Card Styles (Keep from previous) --- */
        .scratch-card-container { display: flex; flex-direction: column; align-items: center; padding: 20px; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); margin-bottom: 20px; }
        .scratch-card-area { width: 250px; height: 150px; position: relative; margin-bottom: 20px; cursor: grab; border-radius: var(--border-radius); overflow: hidden; } .scratch-card-area.revealed { cursor: default; }
        .scratch-result { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background-color: var(--accent-light); font-size: 1.8rem; font-weight: bold; color: var(--accent-dark); z-index: 1; text-align: center; }
        .scratch-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(45deg, var(--secondary-color), var(--secondary-dark)); z-index: 2; transition: opacity 0.5s ease-out; display: flex; align-items: center; justify-content: center; color: white; font-style: italic; font-size: 1.2rem; }
        .scratch-card-area.revealed .scratch-overlay { opacity: 0; pointer-events: none; }
        #scratch-get-button { background-color: var(--warning-color); color: var(--dark-color); } #scratch-get-button:hover { background-color: var(--warning-dark); }
        #scratch-status { margin-top: 15px; font-size: 1.1rem; font-weight: bold; color: var(--primary-dark); min-height: 1.5em; }
        .scratch-info { font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 10px; }

        /* --- Redeem/Withdraw Page Styles (Keep from previous) --- */
        .redeem-page { padding: 30px 20px; background-color: var(--surface-color); border-radius: var(--border-radius); box-shadow: var(--shadow-sm); }
        .redeem-page h2 { color: var(--primary-dark); text-align: center; } .redeem-page .current-balance { text-align: center; font-size: 1.2rem; margin-bottom: 25px; }
        #withdraw-form { max-width: 500px; margin: 0 auto; } #withdraw-form label { font-weight: 500; }
        #withdraw-form .form-group input, #withdraw-form .form-group select { background-color: #fdfdfe; }
        #withdraw-result { margin-top: 20px; text-align: center; font-weight: bold; }

        /* --- Loading Spinner (Keep from previous) --- */
        .spinner { border: 4px solid var(--secondary-light); border-top: 4px solid var(--primary-color); border-radius: 50%; width: 24px; height: 24px; animation: spin 1s linear infinite; margin: 0 auto; display: none; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        button .spinner { display: inline-block; vertical-align: middle; margin-left: 8px; width: 16px; height: 16px; border-width: 2px; }
        button.loading .button-text { display: none; } button:not(.loading) .spinner { display: none; }

        /* --- Responsive Styles (Keep from previous) --- */
        @media (min-width: 768px) {
            body { font-size: 16px; } .main-content { padding: calc(var(--header-height) + 30px) 30px 30px 30px; } .dashboard-section { padding: 25px; margin-bottom: 25px; }
            .logo { position: static; transform: none; margin-left: 10px; } .user-profile-icon span { display: inline; } .stats-panel { grid-template-columns: repeat(2, 1fr); gap: 20px; }
            .spin-button { width: auto; max-width: none; padding: 12px 30px; } .feature-grid { grid-template-columns: repeat(2, 1fr); gap: 20px; } .feature-card { align-items: center; text-align: center; padding: 25px; }
            .feature-header { flex-direction: column; align-items: center; margin-bottom: 10px; } .feature-icon { margin-right: 0; margin-bottom: 10px; width: 45px; height: 45px; font-size: 1.4rem; }
            .feature-card h4 { text-align: center; margin-bottom: 10px; } .feature-card p { text-align: center; } .feature-button { align-self: center; } .activity-list li { font-size: 0.95rem; } .view-all-activity { text-align: right; font-size: 1rem; }
            .spin-wheel-graphic { width: 350px; height: 350px; } .wheel-segment { font-size: 1rem; } /* Increase wheel text size */
            .slots-reels { gap: 15px; } .reel { width: 70px; height: 210px; } .reel-symbol { height: 70px; font-size: 3rem; } .scratch-card-area { width: 300px; height: 180px; } .auth-page { margin: 60px auto; }
        }
        @media (min-width: 992px) {
             body { display: block; overflow-x: visible; } .dashboard-container { display: grid; grid-template-columns: var(--sidebar-width) 1fr; grid-template-rows: var(--header-height) auto; grid-template-areas: "sidebar header" "sidebar main"; width: 100%; min-height: 100vh; }
            .header { position: relative; grid-area: header; border-bottom: 1px solid var(--border-color); box-shadow: none; padding: 0 30px; justify-content: flex-end; }
            #menu-toggle { display: none; } .logo { display: none; } .sidebar { position: sticky; top: 0; left: 0; height: 100vh; grid-area: sidebar; padding-top: 20px; border-right: 1px solid var(--border-color); box-shadow: none; }
            .overlay { display: none !important; } .main-content { grid-area: main; margin-left: 0; padding: 30px; width: 100%; }
            h1 { font-size: 1.8rem; } h2 { font-size: 1.6rem; } h3 { font-size: 1.3rem; } h4 { font-size: 1.1rem; } .stats-panel { grid-template-columns: repeat(4, 1fr); }
             #dashboard-content .feature-grid { grid-template-columns: repeat(2, 1fr); } .feature-icon { width: 50px; height: 50px; font-size: 1.6rem; }
        }
         @media (min-width: 1200px) {
            .main-content { max-width: 1140px; margin: 0 auto; padding: 40px; } #dashboard-content .feature-grid { grid-template-columns: repeat(4, 1fr); gap: 25px; }
             .dashboard-section { padding: 30px; margin-bottom: 30px; } .stats-panel { gap: 25px; }
              .spin-wheel-graphic { width: 400px; height: 400px; } .wheel-segment { font-size: 1.1rem; } /* Increase wheel text size further */
              .slots-reels { gap: 20px; } .reel { width: 80px; height: 240px; } .reel-symbol { height: 80px; font-size: 3.5rem; } .scratch-card-area { width: 350px; height: 210px; }
        }
    </style>
</head>
<body class="logged-out"> <!-- Start in logged-out state -->
    <div id="overlay"></div>

    <div class="dashboard-container">

        <header class="header">
            <button id="menu-toggle" aria-label="Toggle Menu"><i class="fas fa-bars"></i></button>
            <h1 class="logo">SpinEarn</h1>
            <div class="user-profile-icon">
                <i class="fas fa-user-circle"></i>
                <span id="user-greeting">Hi, Guest!</span>
            </div>
        </header>

        <aside class="sidebar" id="sidebar">
            <nav class="sidebar-nav">
                 <ul>
                    <!-- Auth Links -->
                    <li class="nav-auth-link nav-login-link"><a href="#login"><i class="fas fa-sign-in-alt"></i> Login</a></li>
                    <li class="nav-auth-link nav-register-link"><a href="#register"><i class="fas fa-user-plus"></i> Register</a></li>
                    <!-- App Links -->
                    <li class="active"><a href="#dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="#spin-wheel"><i class="fas fa-dharmachakra"></i> Spin Wheel</a></li>
                    <li><a href="#slot-machine"><i class="fas fa-dice"></i> Slot Machine</a></li>
                    <li><a href="#scratch-cards"><i class="fas fa-ticket-alt"></i> Scratch Cards</a></li>
                    <li><a href="#daily-bonus"><i class="fas fa-calendar-check"></i> Daily Bonus</a></li>
                    <li><a href="#refer-earn"><i class="fas fa-user-plus"></i> Refer & Earn</a></li>
                    <li><a href="#redeem"><i class="fas fa-gift"></i> Redeem Points</a></li>
                    <li><a href="#history"><i class="fas fa-history"></i> History</a></li>
                    <li><a href="#profile"><i class="fas fa-user"></i> Profile</a></li>
                    <!-- Logout Link -->
                    <li class="nav-logout-link"><a href="#logout" id="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </nav>
        </aside>

        <main class="main-content">

             <!-- Login Page Content -->
             <div id="login-content" class="page-content active-page">
                <div class="auth-page">
                    <h2>Login</h2>
                    <div id="login-error-message" class="error-message" style="display: none;"></div>
                    <form id="login-form">
                        <div class="form-group"> <label for="login-username">Username</label> <input type="text" id="login-username" name="username" required> </div>
                        <div class="form-group"> <label for="login-password">Password</label> <input type="password" id="login-password" name="password" required> </div>
                        <button type="submit" class="auth-button"> <span class="button-text">Login</span> <div class="spinner"></div> </button>
                    </form>
                    <a href="#register" class="auth-switch-link internal-nav-link">Don't have an account? Register here</a>
                </div>
            </div>

            <!-- Register Page Content -->
            <div id="register-content" class="page-content">
                 <div class="auth-page">
                    <h2>Register</h2>
                    <div id="register-error-message" class="error-message" style="display: none;"></div>
                     <div id="register-success-message" class="success-message" style="display: none;"></div>
                    <form id="register-form">
                        <div class="form-group"> <label for="register-username">Username</label> <input type="text" id="register-username" name="username" required minlength="3" maxlength="50" pattern="^[a-zA-Z0-9_]+$"> <small>Letters, numbers, underscore only. 3-50 chars.</small> </div>
                        <div class="form-group"> <label for="register-password">Password</label> <input type="password" id="register-password" name="password" required minlength="6"> <small>Minimum 6 characters.</small> </div>
                        <div class="form-group"> <label for="register-confirm-password">Confirm Password</label> <input type="password" id="register-confirm-password" name="confirmPassword" required> </div>
                        <button type="submit" class="auth-button"> <span class="button-text">Register</span> <div class="spinner"></div> </button>
                    </form>
                     <a href="#login" class="auth-switch-link internal-nav-link">Already have an account? Login here</a>
                </div>
            </div>

            <!-- Dashboard Content -->
            <div id="dashboard-content" class="page-content">
                <section class="welcome-section dashboard-section"> <h2 id="welcome-message">Welcome Back!</h2> <p>Your gaming summary awaits below.</p> </section>
                <section class="stats-panel">
                    <div class="stat-card"><div class="icon bg-accent"><i class="fas fa-coins"></i></div><div class="stat-info"><span class="label">Balance</span><span class="value" id="stat-points">--- pts</span></div></div>
                    <div class="stat-card"><div class="icon bg-primary"><i class="fas fa-sync-alt"></i></div><div class="stat-info"><span class="label">Spins Left</span><span class="value" id="stat-spins">-- / --</span></div></div>
                    <div class="stat-card"><div class="icon bg-danger"><i class="fas fa-dice-three"></i></div><div class="stat-info"><span class="label">Slot Tokens</span><span class="value" id="stat-tokens">---</span></div></div>
                    <div class="stat-card"><div class="icon bg-warning"><i class="fas fa-ticket-alt"></i></div><div class="stat-info"><span class="label">Scratch Cards</span><span class="value" id="stat-scratch">---</span></div></div>
                </section>
                <section class="spin-action-section dashboard-section"> <h3>Ready for Your Next Spin?</h3> <p>Try your luck on the wheel and win points!</p> <button class="spin-button" data-target-page="#spin-wheel"><i class="fas fa-play-circle"></i> Go to Spin Wheel</button> </section>
                <section class="feature-grid">
                    <div class="feature-card daily-bonus"><div class="feature-header"><div class="feature-icon"><i class="fas fa-calendar-check"></i></div><h4>Daily Bonus</h4></div><p>Claim your free points every day!</p><button class="feature-button" data-target-page="#daily-bonus"><i class="fas fa-gift"></i> Go to Daily Bonus</button></div>
                    <div class="feature-card slots"><div class="feature-header"><div class="feature-icon"><i class="fas fa-dice-three"></i></div><h4>Slot Machine</h4></div><p>Match the symbols and win big payouts.</p><button class="feature-button" data-target-page="#slot-machine"><i class="fas fa-play"></i> Play Slots</button></div>
                    <div class="feature-card scratch"><div class="feature-header"><div class="feature-icon"><i class="fas fa-hand-sparkles"></i></div> <h4>Scratch Cards</h4></div><p>Reveal hidden prizes instantly.</p><button class="feature-button" data-target-page="#scratch-cards"><i class="fas fa-ticket-alt"></i> Get Cards</button></div>
                    <div class="feature-card refer"><div class="feature-header"><div class="feature-icon"><i class="fas fa-share-alt"></i></div><h4>Refer & Earn</h4></div><p>Invite friends and earn bonus points.</p><button class="feature-button" data-target-page="#refer-earn"><i class="fas fa-user-plus"></i> Invite Friends</button></div>
                </section>
                <section class="activity-log dashboard-section"> <h3>Recent Activity</h3> <ul class="activity-list" id="dashboard-activity-list"><li>Loading activity...</li></ul> <a href="#history" class="view-all-activity internal-nav-link">View All Activity</a> </section>
            </div>

            <!-- Spin Wheel Content -->
            <div id="spin-wheel-content" class="page-content">
                <h2>Spin the Wheel!</h2>
                <div class="spin-wheel-container">
                    <div class="spin-wheel-graphic"> <div class="wheel" id="wheel"><!-- Segments added by JS --></div> <div class="wheel-pointer"></div> </div>
                    <p>Spins Left: <strong id="spin-page-spins-left">--</strong></p>
                    <button id="spin-action-button" class="action-button"><span class="button-text"><i class="fas fa-play"></i> Spin Now</span><div class="spinner"></div></button>
                    <div id="spin-result">Spin to see your prize!</div>
                </div>
            </div>

             <!-- Slot Machine Content -->
            <div id="slot-machine-content" class="page-content">
                 <h2>Slot Machine</h2>
                 <div class="slots-container">
                    <p class="slot-info">Cost: <strong id="slot-cost">1 Token</strong> | Your Tokens: <strong id="slot-tokens-available">--</strong></p>
                    <div class="slots-reels"> <div class="reel"><div class="reel-symbols" id="reel1"></div></div> <div class="reel"><div class="reel-symbols" id="reel2"></div></div> <div class="reel"><div class="reel-symbols" id="reel3"></div></div> </div>
                    <button id="slots-play-button" class="action-button"><span class="button-text"><i class="fas fa-play"></i> Play (1 Token)</span><div class="spinner"></div></button>
                    <div id="slots-result">Match the symbols to win!</div>
                 </div>
            </div>

             <!-- Scratch Cards Content -->
            <div id="scratch-cards-content" class="page-content">
                 <h2>Scratch & Win</h2>
                 <div class="scratch-card-container">
                    <p class="scratch-info">Cards Left Today: <strong id="scratch-cards-left">--</strong></p>
                    <div class="scratch-card-area" id="scratch-card-area"> <div class="scratch-result" id="scratch-result-display">?</div> <div class="scratch-overlay" id="scratch-overlay">Click to Scratch!</div> </div>
                    <button id="scratch-get-button" class="action-button"><span class="button-text"><i class="fas fa-hand-sparkles"></i> Scratch Card</span><div class="spinner"></div></button>
                    <div id="scratch-status">Click the card above!</div>
                 </div>
            </div>

             <!-- Daily Bonus Content -->
            <div id="daily-bonus-content" class="page-content">
                 <div class="placeholder-page">
                     <i class="fas fa-calendar-check page-icon"></i> <h2>Daily Bonus</h2>
                    <p id="daily-bonus-message">Checking eligibility...</p>
                    <button class="action-button" id="claim-daily-bonus-page-button"><span class="button-text"><i class="fas fa-gift"></i> Claim Today's Bonus</span><div class="spinner"></div></button>
                    <div id="daily-bonus-status" style="margin-top: 15px; font-weight: bold;"></div>
                </div>
            </div>

             <!-- Refer & Earn Content -->
            <div id="refer-earn-content" class="page-content">
                 <div class="placeholder-page">
                    <i class="fas fa-user-plus page-icon"></i> <h2>Refer & Earn</h2>
                    <p>Share your referral code with friends. You both earn bonus points when they sign up!</p>
                    <p>Your Referral Code:</p> <p><strong id="referral-code" style="font-size: 1.4em; background: var(--light-color); padding: 5px 10px; border-radius: 4px; border: 1px solid var(--border-color); display: inline-block; margin-bottom: 15px;">CODE-LOADING</strong></p>
                    <button class="action-button" id="copy-referral-button"><i class="fas fa-copy"></i> Copy Code</button>
                    <div id="copy-status" style="margin-top: 10px; color: var(--success-color); min-height: 1em;"></div>
                    <p style="margin-top: 20px; font-size: 0.9em;">(Referral tracking not implemented in this demo)</p>
                </div>
            </div>

             <!-- Redeem Points Content (Withdrawal Simulation) -->
            <div id="redeem-content" class="page-content">
                 <div class="redeem-page">
                    <h2>Redeem Points (Withdrawal Simulation)</h2>
                    <p class="current-balance">Your Balance: <strong id="redeem-points-balance">--- Points</strong></p>
                    <div id="withdraw-error-message" class="error-message" style="display: none;"></div> <div id="withdraw-success-message" class="success-message" style="display: none;"></div>
                    <form id="withdraw-form">
                        <div class="form-group"> <label for="withdraw-amount">Amount (Points)</label> <input type="number" id="withdraw-amount" name="amount" required min="100" placeholder="Min 100 points"> </div>
                        <div class="form-group"> <label for="withdraw-method">Withdrawal Method</label> <select id="withdraw-method" name="method" required> <option value="">-- Select Method --</option> <option value="paypal">PayPal</option> <option value="bank">Bank Transfer (Simulated)</option> <option value="voucher">Gift Voucher (Simulated)</option> </select> </div>
                        <div class="form-group"> <label for="withdraw-details">Details (e.g., PayPal Email)</label> <input type="text" id="withdraw-details" name="details" required placeholder="Enter relevant details"> <small style="color: var(--danger-color); display: block; margin-top: 5px;"><strong>Simulation Only:</strong> Do not enter real financial details.</small> </div>
                        <button type="submit" class="auth-button"> <span class="button-text">Request Withdrawal</span> <div class="spinner"></div> </button>
                    </form>
                     <div id="withdraw-result" style="margin-top: 20px; text-align: center; font-weight: bold;"></div>
                 </div>
            </div>

             <!-- History Content -->
            <div id="history-content" class="page-content">
                <section class="activity-log dashboard-section"> <h2>Activity History</h2> <p>A complete log of your earnings and activities.</p> <ul class="activity-list" id="full-activity-list"><li>Loading history...</li></ul> </section>
            </div>

             <!-- Profile Content -->
            <div id="profile-content" class="page-content">
                 <div class="placeholder-page">
                    <i class="fas fa-user-edit page-icon"></i> <h2>Profile</h2>
                    <p>Username: <strong id="profile-username">---</strong></p>
                    <p>Member Since: <strong id="profile-created-at">---</strong></p>
                    <button class="action-button"><i class="fas fa-key"></i> Change Password (Not Implemented)</button>
                </div>
            </div>

        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // --- Global Elements & State Cache (Keep as is) ---
            const body = document.body; const menuToggle = document.getElementById('menu-toggle'); const sidebar = document.getElementById('sidebar'); const overlay = document.getElementById('overlay'); const sidebarLinks = document.querySelectorAll('.sidebar-nav a'); const mainContent = document.querySelector('.main-content'); const userGreeting = document.getElementById('user-greeting'); const logoutLink = document.getElementById('logout-link'); const loginForm = document.getElementById('login-form'); const registerForm = document.getElementById('register-form'); const loginErrorMessage = document.getElementById('login-error-message'); const registerErrorMessage = document.getElementById('register-error-message'); const registerSuccessMessage = document.getElementById('register-success-message'); const welcomeMessage = document.getElementById('welcome-message'); const statPoints = document.getElementById('stat-points'); const statSpins = document.getElementById('stat-spins'); const statTokens = document.getElementById('stat-tokens'); const statScratch = document.getElementById('stat-scratch'); const dashboardActivityList = document.getElementById('dashboard-activity-list'); const wheelElement = document.getElementById('wheel'); const spinButton = document.getElementById('spin-action-button'); const spinResultEl = document.getElementById('spin-result'); const spinPageSpinsLeft = document.getElementById('spin-page-spins-left'); const reelElements = [document.getElementById('reel1'), document.getElementById('reel2'), document.getElementById('reel3')]; const slotsPlayButton = document.getElementById('slots-play-button'); const slotsResultEl = document.getElementById('slots-result'); const slotTokensAvailable = document.getElementById('slot-tokens-available'); const slotCostEl = document.getElementById('slot-cost'); const scratchCardArea = document.getElementById('scratch-card-area'); const scratchResultDisplay = document.getElementById('scratch-result-display'); const scratchOverlay = document.getElementById('scratch-overlay'); const scratchButton = document.getElementById('scratch-get-button'); const scratchStatusEl = document.getElementById('scratch-status'); const scratchCardsLeftEl = document.getElementById('scratch-cards-left'); const claimBonusPageButton = document.getElementById('claim-daily-bonus-page-button'); const dailyBonusStatusEl = document.getElementById('daily-bonus-status'); const dailyBonusMessageEl = document.getElementById('daily-bonus-message'); const referralCodeEl = document.getElementById('referral-code'); const copyReferralButton = document.getElementById('copy-referral-button'); const copyStatusEl = document.getElementById('copy-status'); const redeemPointsBalance = document.getElementById('redeem-points-balance'); const withdrawForm = document.getElementById('withdraw-form'); const withdrawAmountInput = document.getElementById('withdraw-amount'); const withdrawResultEl = document.getElementById('withdraw-result'); const withdrawErrorMessage = document.getElementById('withdraw-error-message'); const withdrawSuccessMessage = document.getElementById('withdraw-success-message'); const fullActivityListEl = document.getElementById('full-activity-list'); const profileUsernameEl = document.getElementById('profile-username'); const profileCreatedAtEl = document.getElementById('profile-created-at');
            let userData = null; let isLoggedIn = false; let isSpinning = false; let isSlotSpinning = false; let isScratching = false;

            // API Endpoints (Keep as is)
            const API_BASE_URL = ''; const API_REGISTER = API_BASE_URL + 'api_register.php'; const API_LOGIN = API_BASE_URL + 'api_login.php'; const API_LOGOUT = API_BASE_URL + 'api_logout.php'; const API_GET_DATA = API_BASE_URL + 'api_get_data.php'; const API_SPIN = API_BASE_URL + 'api_spin.php'; const API_SLOTS = API_BASE_URL + 'api_slots.php'; const API_SCRATCH = API_BASE_URL + 'api_scratch.php'; const API_CLAIM_BONUS = API_BASE_URL + 'api_claim_bonus.php';

            // Spin Wheel Config (Keep as is)
            const spinWheelSegments = [ { prize: 10, label: '10 Pts', color: '#FFDDC1' }, { prize: 15, label: '15 Pts', color: '#FFFACD' }, { prize: 20, label: '20 Pts', color: '#D0F0C0' }, { prize: 25, label: '25 Pts', color: '#C1FFD7' }, { prize: 30, label: '30 Pts', color: '#B0E0E6' }, { prize: 35, label: '35 Pts', color: '#ADD8E6' }, { prize: 40, label: '40 Pts', color: '#E6E6FA' }, { prize: 50, label: '50 Pts', color: '#F5DEB3' }, ]; const numSegments = spinWheelSegments.length; const segmentAngle = 360 / numSegments;

            // Slot Config (Keep as is)
            const slotSymbols = ['🍒', '🍋', '🍊', '🍉', '⭐', '🔔', '７']; const symbolsPerReel = 20; const symbolHeight = 60;

            // --- Utility Functions (Keep as is) ---
            const showLoading = (button) => { if (!button) return; button.classList.add('loading'); button.disabled = true; }; const hideLoading = (button) => { if (!button) return; button.classList.remove('loading'); }; const formatTimeAgo = (timestamp) => { if (!timestamp) return ''; const date = new Date(timestamp.replace(' ', 'T') + 'Z'); const now = new Date(); const seconds = Math.round((now - date) / 1000); const minutes = Math.round(seconds / 60); const hours = Math.round(minutes / 60); const days = Math.round(hours / 24); if (seconds < 60) return `${seconds} sec ago`; if (minutes < 60) return `${minutes} min ago`; if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`; return `${days} day${days > 1 ? 's' : ''} ago`; }; const displayMessage = (element, message, isError = true) => { if (!element) return; element.textContent = message; element.style.display = message ? 'block' : 'none'; element.className = isError ? 'error-message' : 'success-message'; };

            // --- UI Update Functions (Keep as is) ---
            const updateLoginStateUI = () => { if (isLoggedIn) { body.classList.remove('logged-out'); userGreeting.textContent = `Hi, ${userData?.username || 'User'}!`; if (!mainContent.querySelector('.page-content.active-page') || mainContent.querySelector('#login-content.active-page') || mainContent.querySelector('#register-content.active-page')) { switchPage('#dashboard'); } } else { body.classList.add('logged-out'); userGreeting.textContent = 'Hi, Guest!'; userData = null; switchPage('#login'); statPoints.textContent = '--- pts'; statSpins.textContent = '-- / --'; statTokens.textContent = '---'; statScratch.textContent = '---'; dashboardActivityList.innerHTML = '<li>Login to see activity.</li>'; fullActivityListEl.innerHTML = '<li>Login to see history.</li>'; } if (sidebar.classList.contains('open') && window.getComputedStyle(sidebar).position === 'fixed') { toggleSidebar(); } };
            const updateUserDataUI = (data) => { userData = data; if (!isLoggedIn || !userData) return; welcomeMessage.textContent = `Welcome Back, ${data.username || 'User'}!`; statPoints.textContent = `${data.points?.toLocaleString() || 0} pts`; statSpins.textContent = `${data.spins_left ?? '--'} / ${data.spins_total ?? '--'}`; statTokens.textContent = `${data.slots_tokens?.toLocaleString() ?? '---'}`; statScratch.textContent = `${data.scratch_cards_left?.toLocaleString() ?? '---'}`; redeemPointsBalance.textContent = `${data.points?.toLocaleString() || 0} Points`; profileUsernameEl.textContent = data.username || 'User'; profileCreatedAtEl.textContent = data.created_at ? new Date(data.created_at.replace(' ', 'T')+'Z').toLocaleDateString() : 'N/A'; referralCodeEl.textContent = `${data.username?.toUpperCase() || 'USER'}REF`; dashboardActivityList.innerHTML = ''; if (data.activity && data.activity.length > 0) { data.activity.slice(0, 5).forEach(item => { const li = document.createElement('li'); li.innerHTML = `<span class="activity-icon ${item.activity_type}"><i class="${getActivityIcon(item.activity_type)}"></i></span><span class="activity-description">${item.description}</span><span class="activity-time">${formatTimeAgo(item.timestamp)}</span>`; dashboardActivityList.appendChild(li); }); } else { dashboardActivityList.innerHTML = '<li>No recent activity.</li>'; } updateFullActivityList(data.activity); spinPageSpinsLeft.textContent = data.spins_left ?? '--'; spinButton.disabled = (data.spins_left <= 0 || isSpinning); slotTokensAvailable.textContent = data.slots_tokens?.toLocaleString() ?? '--'; slotsPlayButton.disabled = (data.slots_tokens <= 0 || isSlotSpinning); scratchCardsLeftEl.textContent = data.scratch_cards_left?.toLocaleString() ?? '--'; scratchButton.disabled = (data.scratch_cards_left <= 0 || isScratching); resetScratchCardVisual(); updateDailyBonusUI(data.can_claim_bonus); };
            const getActivityIcon = (type) => { switch (type) { case 'spin_win': return 'fas fa-trophy'; case 'bonus_claim': return 'fas fa-calendar-check'; case 'slot_win': return 'fas fa-dice'; case 'referral': return 'fas fa-user-plus'; case 'scratch_win': return 'fas fa-ticket-alt'; case 'redeem': return 'fas fa-gift'; case 'withdrawal_request': return 'fas fa-paper-plane'; case 'spin_loss': case 'slot_loss': case 'scratch_loss': return 'fas fa-times-circle'; default: return 'fas fa-info-circle'; } };
            const updateFullActivityList = (activityData) => { if (!fullActivityListEl) return; fullActivityListEl.innerHTML = ''; if (activityData && activityData.length > 0) { activityData.forEach(item => { const li = document.createElement('li'); li.innerHTML = `<span class="activity-icon ${item.activity_type}"><i class="${getActivityIcon(item.activity_type)}"></i></span><span class="activity-description">${item.description}</span><span class="activity-time">${formatTimeAgo(item.timestamp)}</span>`; fullActivityListEl.appendChild(li); }); } else { fullActivityListEl.innerHTML = '<li>No activity records found.</li>'; } };

            // --- Initial Data Load / Session Check (Keep as is) ---
            const checkLoginAndLoadData = async () => { try { const response = await fetch(API_GET_DATA, { credentials: 'include' }); if (response.status === 401) { isLoggedIn = false; updateLoginStateUI(); return; } if (!response.ok) { throw new Error(`HTTP error! status: ${response.status}`); } const result = await response.json(); if (result.success && result.data) { isLoggedIn = true; updateLoginStateUI(); updateUserDataUI(result.data); initializeSpinWheel(); initializeSlots(); } else { console.error("Failed to load initial data:", result.message); isLoggedIn = false; updateLoginStateUI(); displayMessage(loginErrorMessage, "Error loading user data. Try logging in."); } } catch (error) { console.error("Error checking login status:", error); isLoggedIn = false; updateLoginStateUI(); displayMessage(loginErrorMessage, "Network error. Check connection."); } };

            // --- Sidebar & Page Navigation (Keep as is) ---
            const toggleSidebar = () => { const isOpen = sidebar.classList.contains('open'); sidebar.classList.toggle('open'); overlay.classList.toggle('active'); document.body.style.overflow = (!isOpen && window.innerWidth < 992) ? 'hidden' : ''; }; menuToggle?.addEventListener('click', toggleSidebar); overlay?.addEventListener('click', toggleSidebar);
            const switchPage = (targetId) => { if (!targetId || targetId === '#') return; if (targetId === '#logout') { handleLogout(); return; } const protectedPages = ['#dashboard', '#spin-wheel', '#slot-machine', '#scratch-cards', '#daily-bonus', '#refer-earn', '#redeem', '#history', '#profile']; if (!isLoggedIn && protectedPages.includes(targetId)) { switchPage('#login'); return; } if (isLoggedIn && (targetId === '#login' || targetId === '#register')) { switchPage('#dashboard'); return; } const contentId = targetId.substring(1) + '-content'; const targetPage = document.getElementById(contentId); const currentPageEl = mainContent.querySelector('.page-content.active-page'); if(currentPageEl && currentPageEl.id === contentId) return; currentPageEl?.classList.remove('active-page'); if (targetPage) { targetPage.classList.add('active-page'); if(isLoggedIn && targetId === '#history' && userData?.activity) { updateFullActivityList(userData.activity); } } else { console.warn(`Content for ${contentId} not found.`); const fallbackTarget = isLoggedIn ? '#dashboard' : '#login'; document.getElementById(fallbackTarget.substring(1) + '-content')?.classList.add('active-page'); } sidebarLinks.forEach(sLink => { sLink.closest('li').classList.toggle('active', sLink.getAttribute('href') === targetId); }); if (sidebar.classList.contains('open') && window.getComputedStyle(sidebar).position === 'fixed') { toggleSidebar(); } };
            sidebarLinks.forEach(link => { if (link.id !== 'logout-link') { link.addEventListener('click', (e) => { e.preventDefault(); switchPage(link.getAttribute('href')); }); } }); document.querySelectorAll('[data-target-page]').forEach(button => { button.addEventListener('click', (e) => { e.preventDefault(); switchPage(button.dataset.targetPage); }); }); document.querySelectorAll('.internal-nav-link').forEach(link => { link.addEventListener('click', (e) => { e.preventDefault(); switchPage(link.getAttribute('href')); }); });

             // --- Authentication Logic (Keep as is) ---
            loginForm?.addEventListener('submit', async (e) => { e.preventDefault(); displayMessage(loginErrorMessage, '', false); const username = loginForm.username.value.trim(); const password = loginForm.password.value; const button = loginForm.querySelector('button[type="submit"]'); showLoading(button); try { const response = await fetch(API_LOGIN, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ username, password }), credentials: 'include' }); const result = await response.json(); if (result.success) { isLoggedIn = true; await checkLoginAndLoadData(); } else { displayMessage(loginErrorMessage, result.message || 'Login failed.'); isLoggedIn = false; updateLoginStateUI(); } } catch (error) { console.error("Login error:", error); displayMessage(loginErrorMessage, 'Network error.'); isLoggedIn = false; updateLoginStateUI(); } finally { hideLoading(button); button.disabled = false; } });
            registerForm?.addEventListener('submit', async (e) => { e.preventDefault(); displayMessage(registerErrorMessage, '', false); displayMessage(registerSuccessMessage, '', false); const username = registerForm.username.value.trim(); const password = registerForm.password.value; const confirmPassword = registerForm.confirmPassword.value; const button = registerForm.querySelector('button[type="submit"]'); if (password !== confirmPassword) { displayMessage(registerErrorMessage, 'Passwords do not match.'); return; } if (password.length < 6) { displayMessage(registerErrorMessage, 'Password min 6 chars.'); return; } if (!/^[a-zA-Z0-9_]+$/.test(username) || username.length < 3 || username.length > 50) { displayMessage(registerErrorMessage, 'Invalid username.'); return; } showLoading(button); try { const response = await fetch(API_REGISTER, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ username, password, confirmPassword }), credentials: 'include' }); const result = await response.json(); if (result.success) { displayMessage(registerSuccessMessage, result.message || 'Registered! Logging in...'); registerForm.reset(); isLoggedIn = true; await checkLoginAndLoadData(); setTimeout(() => { if(isLoggedIn) switchPage('#dashboard'); }, 1500); } else { displayMessage(registerErrorMessage, result.message || 'Registration failed.'); } } catch (error) { console.error("Registration error:", error); displayMessage(registerErrorMessage, 'Network error.'); } finally { hideLoading(button); button.disabled = false; } });
            const handleLogout = async () => { try { const response = await fetch(API_LOGOUT, { method: 'POST', credentials: 'include' }); const result = await response.json(); if (result.success) { isLoggedIn = false; userData = null; updateLoginStateUI(); } else { console.error("Logout failed:", result.message); alert("Logout failed."); } } catch (error) { console.error("Logout network error:", error); alert("Network error during logout."); } }; logoutLink?.addEventListener('click', (e) => { e.preventDefault(); handleLogout(); });

            // --- Spin Wheel Logic ---
            const initializeSpinWheel = () => {
                if (!wheelElement) return;
                wheelElement.innerHTML = '';
                spinWheelSegments.forEach((segment, i) => {
                    const segmentEl = document.createElement('div');
                    segmentEl.className = 'wheel-segment';
                    const angle = segmentAngle * i;
                    const skew = 90 - segmentAngle;
                    segmentEl.style.backgroundColor = segment.color;

                    // --- Improved Contrast Logic ---
                    // Function to calculate perceived brightness ( sederhana)
                    const getBrightness = (hexColor) => {
                        const rgb = parseInt(hexColor.substring(1), 16); // Convert hex to integer
                        const r = (rgb >> 16) & 0xff; // Extract red
                        const g = (rgb >> 8) & 0xff; // Extract green
                        const b = (rgb >> 0) & 0xff; // Extract blue
                        // Formula for perceived brightness (YIQ)
                        return (r * 299 + g * 587 + b * 114) / 1000;
                    };
                    const brightness = getBrightness(segment.color);
                    const textColor = brightness > 150 ? 'var(--dark-color)' : 'var(--white-color)'; // Use dark text on light bg, white on dark
                    // --- End Improved Contrast Logic ---

                    segmentEl.style.transform = `rotate(${angle}deg) skewY(-${skew}deg)`;
                    const textSpan = document.createElement('span');
                    textSpan.textContent = segment.label;
                    textSpan.style.color = textColor; // Apply calculated text color
                    segmentEl.appendChild(textSpan);
                    wheelElement.appendChild(segmentEl);
                });
                wheelElement.style.transform = 'rotate(0deg)';
                spinResultEl.textContent = 'Spin to see your prize!';
            };

             const spinTheWheel = async () => { /* Keep async structure */
                if (isSpinning || !isLoggedIn || !userData || userData.spins_left <= 0) return;
                isSpinning = true; showLoading(spinButton); spinResultEl.textContent = 'Spinning...'; spinButton.disabled = true;
                const currentRotation = parseFloat(wheelElement.style.transform.replace(/rotate\(|\)deg/g, '')) || 0;
                const randomExtraRotation = (Math.floor(Math.random() * 5) + 5) * 360;

                try {
                    const response = await fetch(API_SPIN, { method: 'POST', credentials: 'include' });
                    if (!response.ok) { if (response.status === 401) { handleLogout(); return; } throw new Error(`Spin API error! Status: ${response.status}`); }
                    const result = await response.json();

                    if (result.success) {
                         const winningIndex = result.winning_segment_index;
                         const targetSegmentCenterAngle = (segmentAngle * winningIndex) + (segmentAngle / 2);
                         const targetRotation = 360 - targetSegmentCenterAngle;
                         const finalRotation = currentRotation - (currentRotation % 360) + randomExtraRotation + targetRotation;
                         wheelElement.style.transform = `rotate(${finalRotation}deg)`;
                        setTimeout(() => {
                            spinResultEl.textContent = result.message;
                            updateUserDataUI({ ...userData, points: result.new_points, spins_left: result.spins_left });
                            isSpinning = false; spinButton.disabled = (result.spins_left <= 0); hideLoading(spinButton);
                        }, 5100); // Match CSS transition
                    } else { spinResultEl.textContent = `Spin failed: ${result.message}`; isSpinning = false; spinButton.disabled = (userData?.spins_left <= 0); hideLoading(spinButton); }
                } catch (error) { console.error("Error spinning wheel:", error); spinResultEl.textContent = 'Spin error. Try again.'; isSpinning = false; spinButton.disabled = (userData?.spins_left <= 0); hideLoading(spinButton); }
            };
            spinButton?.addEventListener('click', spinTheWheel);


            // --- Slot Machine Logic (Keep as is) ---
            const initializeSlots = () => { reelElements.forEach(reelContainer => { if (!reelContainer) return; reelContainer.innerHTML = ''; for (let i = 0; i < symbolsPerReel; i++) { const symbolEl = document.createElement('div'); symbolEl.className = 'reel-symbol'; symbolEl.textContent = slotSymbols[Math.floor(Math.random() * slotSymbols.length)]; reelContainer.appendChild(symbolEl); } reelContainer.style.top = `-${(symbolsPerReel - 3) * symbolHeight}px`; }); };
            const playSlots = async () => { if (isSlotSpinning || !isLoggedIn || !userData || userData.slots_tokens <= 0) return; isSlotSpinning = true; showLoading(slotsPlayButton); slotsResultEl.textContent = 'Spinning reels...'; reelElements.forEach((reel, index) => { if (!reel) return; const randomOffset = Math.floor(Math.random() * (symbolsPerReel - 5)) * symbolHeight; reel.style.transition = `top ${1 + index * 0.2}s cubic-bezier(0.25, 0.1, 0.25, 1)`; reel.style.top = `-${randomOffset}px`; }); try { const response = await fetch(API_SLOTS, { method: 'POST', credentials: 'include' }); if (!response.ok) { if (response.status === 401) { handleLogout(); return; } throw new Error(`Slots API error! Status: ${response.status}`); } const result = await response.json(); if (result.success) { setTimeout(() => { reelElements.forEach((reelContainer, reelIndex) => { if (!reelContainer) return; reelContainer.style.transition = 'top 0.5s cubic-bezier(0.77, 0, 0.175, 1)'; reelContainer.innerHTML = ''; for (let i = 0; i < symbolsPerReel; i++) { const symbolEl = document.createElement('div'); symbolEl.className = 'reel-symbol'; if (i === symbolsPerReel - 2) { symbolEl.textContent = result.reels[reelIndex]; } else { let randomSymbol; do { randomSymbol = slotSymbols[Math.floor(Math.random() * slotSymbols.length)]; } while ((i === symbolsPerReel - 1 || i === symbolsPerReel - 3) && randomSymbol === result.reels[reelIndex]); symbolEl.textContent = randomSymbol; } reelContainer.appendChild(symbolEl); } reelContainer.style.top = `-${(symbolsPerReel - 3) * symbolHeight}px`; }); setTimeout(() => { slotsResultEl.textContent = result.message; updateUserDataUI({ ...userData, points: result.new_points, slots_tokens: result.new_tokens }); isSlotSpinning = false; hideLoading(slotsPlayButton); slotsPlayButton.disabled = (result.new_tokens <= 0); }, 500); }, 1500); } else { slotsResultEl.textContent = `Play failed: ${result.message}`; isSlotSpinning = false; hideLoading(slotsPlayButton); slotsPlayButton.disabled = (userData?.slots_tokens <= 0); } } catch (error) { console.error("Error playing slots:", error); slotsResultEl.textContent = 'Slot error. Try again.'; isSlotSpinning = false; hideLoading(slotsPlayButton); slotsPlayButton.disabled = (userData?.slots_tokens <= 0); } };
            slotsPlayButton?.addEventListener('click', playSlots);

            // --- Scratch Card Logic (Keep as is) ---
            const resetScratchCardVisual = () => { if(scratchCardArea) scratchCardArea.classList.remove('revealed'); if(scratchOverlay) scratchOverlay.style.opacity = '1'; if(scratchResultDisplay) scratchResultDisplay.textContent = '?'; if(scratchStatusEl) scratchStatusEl.textContent = 'Click the card above!'; }
            const scratchTheCard = async () => { if (isScratching || !isLoggedIn || !userData || userData.scratch_cards_left <= 0) { if (userData && userData.scratch_cards_left <= 0) scratchStatusEl.textContent = 'No cards left today!'; return; } isScratching = true; showLoading(scratchButton); scratchStatusEl.textContent = 'Scratching...'; try { const response = await fetch(API_SCRATCH, { method: 'POST', credentials: 'include' }); if (!response.ok) { if (response.status === 401) { handleLogout(); return; } throw new Error(`Scratch API error! Status: ${response.status}`); } const result = await response.json(); if (result.success) { scratchResultDisplay.textContent = result.prize_won > 0 ? `${result.prize_won} Pts!` : 'No Win'; scratchCardArea.classList.add('revealed'); scratchOverlay.style.opacity = '0'; scratchStatusEl.textContent = result.message; updateUserDataUI({ ...userData, points: result.new_points, scratch_cards_left: result.cards_left }); isScratching = false; hideLoading(scratchButton); scratchButton.disabled = (result.cards_left <= 0); } else { scratchStatusEl.textContent = `Scratch failed: ${result.message}`; isScratching = false; hideLoading(scratchButton); scratchButton.disabled = (userData?.scratch_cards_left <= 0); } } catch (error) { console.error("Error scratching card:", error); scratchStatusEl.textContent = 'Scratch error. Try again.'; isScratching = false; hideLoading(scratchButton); scratchButton.disabled = (userData?.scratch_cards_left <= 0); } };
            scratchButton?.addEventListener('click', scratchTheCard); scratchOverlay?.addEventListener('click', scratchTheCard);

             // --- Daily Bonus Logic (Keep as is) ---
             const updateDailyBonusUI = (canClaim) => { if (!claimBonusPageButton || !dailyBonusStatusEl || !dailyBonusMessageEl) return; if (canClaim) { claimBonusPageButton.disabled = false; hideLoading(claimBonusPageButton); claimBonusPageButton.querySelector('.button-text').textContent = 'Claim Today\'s Bonus'; dailyBonusStatusEl.textContent = 'Bonus available!'; dailyBonusMessageEl.textContent = 'You can claim your daily bonus now.'; } else { claimBonusPageButton.disabled = true; hideLoading(claimBonusPageButton); claimBonusPageButton.querySelector('.button-text').textContent = 'Claimed Today'; dailyBonusStatusEl.textContent = 'Already claimed.'; dailyBonusMessageEl.textContent = 'Claimed today. Check back tomorrow!'; } };
             const claimDailyBonus = async () => { if (!isLoggedIn || !userData || !userData.can_claim_bonus) return; showLoading(claimBonusPageButton); dailyBonusStatusEl.textContent = 'Claiming...'; try { const response = await fetch(API_CLAIM_BONUS, { method: 'POST', credentials: 'include' }); if (!response.ok) { if (response.status === 401) { handleLogout(); return; } throw new Error(`Bonus API error! Status: ${response.status}`); } const result = await response.json(); if (result.success) { dailyBonusStatusEl.textContent = result.message; updateUserDataUI({ ...userData, points: result.new_points, can_claim_bonus: false, last_daily_bonus_claimed: new Date().toISOString().split('T')[0] }); } else { dailyBonusStatusEl.textContent = `Claim failed: ${result.message}`; updateDailyBonusUI(userData.can_claim_bonus); } hideLoading(claimBonusPageButton); } catch (error) { console.error("Error claiming bonus:", error); dailyBonusStatusEl.textContent = 'Bonus claim error.'; hideLoading(claimBonusPageButton); updateDailyBonusUI(userData.can_claim_bonus); } };
             claimBonusPageButton?.addEventListener('click', claimDailyBonus);

            // --- Referral Code Copy (Keep as is) ---
             copyReferralButton?.addEventListener('click', () => { const codeToCopy = referralCodeEl.textContent; navigator.clipboard.writeText(codeToCopy).then(() => { copyStatusEl.textContent = 'Code copied!'; setTimeout(() => { copyStatusEl.textContent = ''; }, 2000); }).catch(err => { console.error('Failed to copy: ', err); copyStatusEl.textContent = 'Copy failed.'; }); });

            // --- Withdraw Simulation Logic (Keep as is) ---
            withdrawForm?.addEventListener('submit', (e) => { e.preventDefault(); displayMessage(withdrawErrorMessage, '', false); displayMessage(withdrawSuccessMessage, '', false); withdrawResultEl.textContent = ''; if (!isLoggedIn || !userData) { displayMessage(withdrawErrorMessage, 'Must be logged in.'); return; } const amount = parseInt(withdrawAmountInput.value, 10); const method = withdrawForm.method.value; const details = withdrawForm.details.value.trim(); const button = withdrawForm.querySelector('button[type="submit"]'); if (isNaN(amount) || amount <= 0) { displayMessage(withdrawErrorMessage, 'Enter valid amount.'); return; } if (amount < 100) { displayMessage(withdrawErrorMessage, 'Min 100 points.'); return; } if (amount > userData.points) { displayMessage(withdrawErrorMessage, 'Insufficient points.'); return; } if (!method) { displayMessage(withdrawErrorMessage, 'Select method.'); return; } if (!details) { displayMessage(withdrawErrorMessage, 'Provide details.'); return; } showLoading(button); withdrawResultEl.textContent = 'Processing request...'; setTimeout(() => { const newPoints = userData.points - amount; const logEntry = { activity_type: 'withdrawal_request', description: `Withdrawal request: ${amount} Pts via ${method}`, points_change: -amount, timestamp: new Date().toISOString().replace('T',' ').substring(0, 19) }; if (!userData.activity) userData.activity = []; userData.activity.unshift(logEntry); updateUserDataUI({ ...userData, points: newPoints }); const dashboardLi = document.createElement('li'); dashboardLi.innerHTML = `<span class="activity-icon ${logEntry.activity_type}"><i class="${getActivityIcon(logEntry.activity_type)}"></i></span><span class="activity-description">${logEntry.description}</span><span class="activity-time">Just now</span>`; dashboardActivityList.insertBefore(dashboardLi, dashboardActivityList.firstChild); if (dashboardActivityList.children.length > 5) dashboardActivityList.lastChild.remove(); hideLoading(button); button.disabled = false; withdrawForm.reset(); withdrawResultEl.textContent = ''; displayMessage(withdrawSuccessMessage, `Request for ${amount} points submitted (Simulation).`); }, 1500); });

            // --- Load initial data / Check session ---
            checkLoginAndLoadData();

        }); // End DOMContentLoaded
    </script>

</body>
</html>