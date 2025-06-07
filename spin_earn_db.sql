-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 14, 2025 at 04:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `spin_earn_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_log`
--

CREATE TABLE `activity_log` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `points_change` bigint(20) DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_log`
--

INSERT INTO `activity_log` (`log_id`, `user_id`, `activity_type`, `description`, `points_change`, `timestamp`) VALUES
(1, 1, 'spin_win', 'Won 25 Points from Spin Wheel (25 Pts)', 25, '2025-04-13 20:10:42'),
(2, 1, 'scratch_loss', 'Scratch Card result: No Win', 0, '2025-04-13 20:14:20'),
(3, 1, 'scratch_win', 'Won 100 Points from Scratch Card', 100, '2025-04-13 20:14:23'),
(4, 1, 'scratch_win', 'Won 20 Points from Scratch Card', 20, '2025-04-13 20:14:24'),
(5, 1, 'bonus_claim', 'Claimed Daily Bonus (25 Pts)', 25, '2025-04-13 20:14:36'),
(6, 1, 'spin_win', 'Won 10 Points from Spin Wheel (10 Pts)', 10, '2025-04-13 20:17:06'),
(7, 1, 'spin_win', 'Won 25 Points from Spin Wheel (25 Pts)', 25, '2025-04-13 20:17:16'),
(8, 1, 'spin_win', 'Won 40 Points from Spin Wheel (40 Pts)', 40, '2025-04-13 20:23:55'),
(9, 1, 'slot_loss', 'Slot Machine result: ７ 🍋 🍒', 0, '2025-04-13 20:24:08'),
(10, 1, 'spin_win', 'Won 40 Points from Spin Wheel (40 Pts)', 40, '2025-04-13 20:40:44'),
(11, 2, 'spin_win', 'Won 50 Points from Spin Wheel (+ 50)', 50, '2025-04-13 20:59:09'),
(12, 2, 'spin_win', 'Won 25 Points from Spin Wheel (+ 25)', 25, '2025-04-13 21:06:32'),
(13, 2, 'spin_win', 'Won 10 Points from Spin Wheel (+ 10)', 10, '2025-04-13 21:41:30'),
(14, 2, 'spin_win', 'Won 5 Points from Spin Wheel (5)', 5, '2025-04-13 21:47:22'),
(15, 2, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-13 21:47:32'),
(16, 3, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-13 21:48:24'),
(17, 3, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-13 21:48:31'),
(18, 3, 'spin_win', 'Won 100 Points from Spin Wheel (100)', 100, '2025-04-13 21:48:37'),
(19, 3, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-13 21:49:35'),
(20, 3, 'slot_loss', 'Slot Machine result: 🍊 🔔 ７', 0, '2025-04-13 21:52:16'),
(21, 3, 'slot_loss', 'Slot Machine result: 🔔 🔔 🍒', 0, '2025-04-13 21:52:19'),
(22, 3, 'slot_loss', 'Slot Machine result: 🍋 🍉 ７', 0, '2025-04-13 21:52:22'),
(23, 3, 'slot_loss', 'Slot Machine result: 🔔 ７ ⭐', 0, '2025-04-13 21:52:24'),
(24, 3, 'slot_loss', 'Slot Machine result: ⭐ 🍊 ⭐', 0, '2025-04-13 21:52:28'),
(25, 3, 'slot_loss', 'Slot Machine result: 🍋 🔔 🍉', 0, '2025-04-13 21:52:32'),
(26, 3, 'slot_loss', 'Slot Machine result: ⭐ ⭐ 🍉', 0, '2025-04-13 21:52:35'),
(27, 3, 'slot_win', 'Slot Machine win: ⭐ ⭐ ⭐ (250 Pts)', 250, '2025-04-13 21:52:38'),
(28, 3, 'slot_loss', 'Slot Machine result: ⭐ 🍉 🍊', 0, '2025-04-13 21:52:47'),
(29, 3, 'slot_loss', 'Slot Machine result: ⭐ 🍋 🍒', 0, '2025-04-13 21:52:51'),
(30, 3, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-14 07:07:29'),
(31, 3, 'bonus_claim', 'Claimed Daily Bonus (25 Pts)', 25, '2025-04-14 07:09:12'),
(32, 4, 'spin_win', 'Won 75 Points from Spin Wheel (75)', 75, '2025-04-14 07:21:34'),
(33, 4, 'bonus_claim', 'Claimed Daily Bonus (25 Pts)', 25, '2025-04-14 07:21:49'),
(34, 4, 'slot_loss', 'Slot Machine result: 🍊 🍒 ７', 0, '2025-04-14 07:22:59'),
(35, 4, 'slot_loss', 'Slot Machine result: 🍉 🔔 🔔', 0, '2025-04-14 07:27:23'),
(36, 4, 'spin_win', 'Won 75 Points from Spin Wheel (75)', 75, '2025-04-14 07:27:48'),
(37, 4, 'spin_win', 'Won 10 Points from Spin Wheel (10)', 10, '2025-04-14 07:28:02'),
(38, 4, 'spin_win', 'Won 20 Points from Spin Wheel (20)', 20, '2025-04-14 07:28:13'),
(39, 4, 'spin_win', 'Won 5 Points from Spin Wheel (5)', 5, '2025-04-14 07:28:20'),
(40, 4, 'slot_loss', 'Slot Machine result: 🍊 🍒 ７', 0, '2025-04-14 07:28:45'),
(41, 4, 'slot_loss', 'Slot Machine result: ７ 🍉 🔔', 0, '2025-04-14 07:28:50'),
(42, 4, 'slot_loss', 'Slot Machine result: ７ 🍊 ⭐', 0, '2025-04-14 07:28:54'),
(43, 4, 'slot_loss', 'Slot Machine result: 🍋 🔔 🍋', 0, '2025-04-14 07:28:58'),
(44, 4, 'slot_loss', 'Slot Machine result: 🍊 🔔 ７', 0, '2025-04-14 07:29:01'),
(45, 4, 'slot_loss', 'Slot Machine result: 🍋 🔔 🍋', 0, '2025-04-14 07:29:05'),
(46, 4, 'slot_loss', 'Slot Machine result: 🍒 🍊 🔔', 0, '2025-04-14 07:29:08'),
(47, 4, 'slot_loss', 'Slot Machine result: 🍋 🍒 ⭐', 0, '2025-04-14 07:29:11');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `points` bigint(20) DEFAULT 0,
  `spins_total` int(11) DEFAULT 5,
  `spins_left` int(11) DEFAULT 5,
  `last_spin_time` timestamp NULL DEFAULT NULL,
  `slots_tokens` int(11) DEFAULT 10,
  `scratch_cards_left` int(11) DEFAULT 3,
  `last_scratch_time` timestamp NULL DEFAULT NULL,
  `last_daily_bonus_claimed` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password_hash`, `points`, `spins_total`, `spins_left`, `last_spin_time`, `slots_tokens`, `scratch_cards_left`, `last_scratch_time`, `last_daily_bonus_claimed`, `created_at`, `updated_at`) VALUES
(1, 'saiyed', '$2y$10$y.HGftKHLUsgyS7rx.Td4eWbHJYxWJTCtOHyKf2BrX9T4V2ybWEla', 285, 5, 0, '2025-04-13 20:40:44', 9, 0, '2025-04-13 20:14:24', '2025-04-13', '2025-04-13 20:09:57', '2025-04-13 20:40:44'),
(2, 'sophiya', '$2y$10$rmcsUg2uXi3b71AYoUlUR.lL0uRChYBpAuqyBKdsFF51qR/QC.dYm', 100, 5, 0, '2025-04-13 21:47:32', 10, 3, NULL, NULL, '2025-04-13 20:58:57', '2025-04-13 21:47:32'),
(3, 'shuaib', '$2y$10$wA3f0aUXWOMlN3WDenHMx.Q00RM20eaKKHodyXjg2a.B0b8EubBJS', 415, 5, 0, '2025-04-14 07:07:29', 0, 3, NULL, '2025-04-14', '2025-04-13 21:48:15', '2025-04-14 07:09:12'),
(4, 'ali', '$2y$10$cYeclGF4P2PM1roENi1zquvi7dTvRiMdCV.8bYBOlwb2nhnH/4Y1m', 210, 5, 0, '2025-04-14 07:28:20', 0, 3, NULL, '2025-04-14', '2025-04-14 07:21:24', '2025-04-14 07:29:11');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_log`
--
ALTER TABLE `activity_log`
  ADD CONSTRAINT `activity_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
