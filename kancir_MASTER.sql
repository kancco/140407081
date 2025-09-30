-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 30, 2025 at 11:37 PM
-- Server version: 10.6.20-MariaDB-cll-lve
-- PHP Version: 8.1.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kancir_cosmetics`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_digits_only_ascii` (`s` VARCHAR(1000)) RETURNS VARCHAR(1000) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  RETURN REGEXP_REPLACE(fn_to_ascii_digits(COALESCE(s,'')), '[^0-9]', '');
END$$

CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_norm_date` (`s` VARCHAR(255)) RETURNS VARCHAR(10) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  DECLARE m VARCHAR(32); DECLARE y VARCHAR(4); DECLARE mm VARCHAR(2); DECLARE dd VARCHAR(2);
  SET m = REGEXP_SUBSTR(fn_to_ascii_digits(s),'(1[34][0-9]{2}|20[0-9]{2})/[0-9]{1,2}/[0-9]{1,2}');
  IF m IS NULL OR m='' THEN RETURN NULL; END IF;
  SET y  = SUBSTRING_INDEX(m,'/',1);
  SET mm = LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(m,'/',2),'/',-1),2,'0');
  SET dd = LPAD(SUBSTRING_INDEX(m,'/',-1),2,'0');
  RETURN fn_to_persian_digits(CONCAT(y,'/',mm,'/',dd));
END$$

CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_norm_gtin` (`s` VARCHAR(255)) RETURNS VARCHAR(32) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  DECLARE d VARCHAR(255);
  SET d = fn_digits_only_ascii(s);
  IF LENGTH(d) IN (8,12,13,14) THEN RETURN fn_to_persian_digits(d); END IF;
  RETURN fn_to_persian_digits(d);
END$$

CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_norm_mobile_ir` (`s` VARCHAR(255)) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  DECLARE d VARCHAR(255);
  SET d = fn_digits_only_ascii(s);
  IF d LIKE '0098%' THEN SET d = CONCAT('0', SUBSTRING(d,5,10));
  ELSEIF d LIKE '98%' THEN SET d = CONCAT('0', SUBSTRING(d,3,10));
  ELSEIF d REGEXP '^9[0-9]{9}$' THEN SET d = CONCAT('0', d);
  END IF;
  RETURN fn_to_persian_digits(d);
END$$

CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_to_ascii_digits` (`s` VARCHAR(1000)) RETURNS VARCHAR(1000) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  SET s = COALESCE(s,'');
  SET s = REPLACE(s,'٠','0'); SET s = REPLACE(s,'١','1'); SET s = REPLACE(s,'٢','2'); SET s = REPLACE(s,'٣','3'); SET s = REPLACE(s,'٤','4');
  SET s = REPLACE(s,'٥','5'); SET s = REPLACE(s,'٦','6'); SET s = REPLACE(s,'٧','7'); SET s = REPLACE(s,'٨','8'); SET s = REPLACE(s,'٩','9');
  SET s = REPLACE(s,'۰','0'); SET s = REPLACE(s,'۱','1'); SET s = REPLACE(s,'۲','2'); SET s = REPLACE(s,'۳','3'); SET s = REPLACE(s,'۴','4');
  SET s = REPLACE(s,'۵','5'); SET s = REPLACE(s,'۶','6'); SET s = REPLACE(s,'۷','7'); SET s = REPLACE(s,'۸','8'); SET s = REPLACE(s,'۹','9');
  RETURN s;
END$$

CREATE DEFINER=`kancir`@`localhost` FUNCTION `fn_to_persian_digits` (`s` VARCHAR(1000)) RETURNS VARCHAR(1000) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
  SET s = fn_to_ascii_digits(COALESCE(s,''));
  SET s = REPLACE(s,'0','۰'); SET s = REPLACE(s,'1','۱'); SET s = REPLACE(s,'2','۲'); SET s = REPLACE(s,'3','۳'); SET s = REPLACE(s,'4','۴');
  SET s = REPLACE(s,'5','۵'); SET s = REPLACE(s,'6','۶'); SET s = REPLACE(s,'7','۷'); SET s = REPLACE(s,'8','۸'); SET s = REPLACE(s,'9','۹');
  RETURN s;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `app_users`
--

CREATE TABLE `app_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `password_sha256` char(64) NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_users`
--

INSERT INTO `app_users` (`id`, `username`, `password_sha256`, `is_admin`, `created_at`, `updated_at`) VALUES
(1, 'fdamaz', 'b72ac3a0020556c874e14324f41b566e0bb0ce8373844311ecba542fdc7792ce', 1, '2025-09-30 20:05:32', '2025-09-30 20:05:32');

-- --------------------------------------------------------

--
-- Table structure for table `factories_raw`
--

CREATE TABLE `factories_raw` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `company_national_id` varchar(32) NOT NULL,
  `company_name_fa` varchar(300) NOT NULL,
  `status_fa` varchar(120) DEFAULT NULL,
  `city_fa` varchar(160) DEFAULT NULL,
  `industry_type_fa` varchar(160) DEFAULT NULL,
  `production_site_type` varchar(160) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `factories_raw`
--
DELIMITER $$
CREATE TRIGGER `trg_fr_bi` BEFORE INSERT ON `factories_raw` FOR EACH ROW BEGIN
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت باید ۱۱ رقم باشد.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_fr_bu` BEFORE UPDATE ON `factories_raw` FOR EACH ROW BEGIN
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت باید ۱۱ رقم باشد.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `factories_whitelist`
--

CREATE TABLE `factories_whitelist` (
  `company_national_id` varchar(32) NOT NULL,
  `company_name_fa` varchar(300) NOT NULL,
  `status_fa` varchar(120) DEFAULT NULL,
  `city_fa` varchar(160) DEFAULT NULL,
  `industry_type_fa` varchar(160) DEFAULT NULL,
  `production_site_type` varchar(160) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `factories_whitelist`
--
DELIMITER $$
CREATE TRIGGER `trg_fw_bi` BEFORE INSERT ON `factories_whitelist` FOR EACH ROW BEGIN
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='company_national_id باید ۱۱ رقم باشد.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_fw_bu` BEFORE UPDATE ON `factories_whitelist` FOR EACH ROW BEGIN
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='company_national_id باید ۱۱ رقم باشد.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `irc_raw`
--

CREATE TABLE `irc_raw` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `irc_code` text NOT NULL,
  `irc_code_sha256` char(64) GENERATED ALWAYS AS (sha2(coalesce(`irc_code`,''),256)) STORED,
  `mother_license_code` text DEFAULT NULL,
  `mother_license_code_sha256` char(64) GENERATED ALWAYS AS (sha2(coalesce(`mother_license_code`,''),256)) STORED,
  `status_fa` varchar(120) DEFAULT NULL,
  `domain_fa` varchar(120) DEFAULT NULL,
  `unit_type_fa` varchar(160) DEFAULT NULL,
  `product_trade_name_fa` varchar(400) DEFAULT NULL,
  `product_generic_name_fa` varchar(400) DEFAULT NULL,
  `gtin` varchar(32) DEFAULT NULL,
  `category_group_code` varchar(120) DEFAULT NULL,
  `license_holder_name_fa` varchar(300) DEFAULT NULL,
  `national_id_license` varchar(32) DEFAULT NULL,
  `manufacturer_name_fa` varchar(300) DEFAULT NULL,
  `manufacturer_national_id` varchar(32) DEFAULT NULL,
  `manufacturer_country_fa` varchar(160) DEFAULT NULL,
  `file_number` varchar(120) DEFAULT NULL,
  `sent_datetime_raw` varchar(10) DEFAULT NULL,
  `final_fix_datetime_raw` varchar(10) DEFAULT NULL,
  `committee_datetime_raw` varchar(10) DEFAULT NULL,
  `committee_letter_number` varchar(120) DEFAULT NULL,
  `committee_letter_datetime_raw` varchar(10) DEFAULT NULL,
  `first_issue_datetime_raw` varchar(10) DEFAULT NULL,
  `issue_datetime_raw` varchar(10) DEFAULT NULL,
  `expire_datetime_raw` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `irc_raw`
--
DELIMITER $$
CREATE TRIGGER `trg_irc_raw_bi` BEFORE INSERT ON `irc_raw` FOR EACH ROW BEGIN
  SET NEW.irc_code            = fn_to_persian_digits(NEW.irc_code);
  SET NEW.mother_license_code = fn_to_persian_digits(NEW.mother_license_code);
  SET NEW.national_id_license      = fn_to_persian_digits(fn_digits_only_ascii(NEW.national_id_license));
  SET NEW.manufacturer_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.manufacturer_national_id));
  IF NEW.national_id_license IS NOT NULL AND NEW.national_id_license<>'' AND LENGTH(fn_digits_only_ascii(NEW.national_id_license)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی مالک پروانه باید ۱۱ رقم باشد.'; END IF;
  IF NEW.manufacturer_national_id IS NOT NULL AND NEW.manufacturer_national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.manufacturer_national_id)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی تولیدکننده باید ۱۱ رقم باشد.'; END IF;
  SET NEW.gtin = fn_norm_gtin(NEW.gtin);
  IF NEW.gtin IS NOT NULL AND NEW.gtin<>'' AND LENGTH(fn_digits_only_ascii(NEW.gtin)) NOT IN (8,12,13,14)
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='GTIN باید ۸/۱۲/۱۳/۱۴ رقم باشد.'; END IF;
  SET NEW.sent_datetime_raw             = fn_norm_date(NEW.sent_datetime_raw);
  SET NEW.final_fix_datetime_raw        = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.committee_datetime_raw        = fn_norm_date(NEW.committee_datetime_raw);
  SET NEW.committee_letter_datetime_raw = fn_norm_date(NEW.committee_letter_datetime_raw);
  SET NEW.first_issue_datetime_raw      = fn_norm_date(NEW.first_issue_datetime_raw);
  SET NEW.issue_datetime_raw            = fn_norm_date(NEW.issue_datetime_raw);
  SET NEW.expire_datetime_raw           = fn_norm_date(NEW.expire_datetime_raw);
  SET NEW.file_number              = fn_to_persian_digits(NEW.file_number);
  SET NEW.committee_letter_number  = fn_to_persian_digits(NEW.committee_letter_number);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_irc_raw_bu` BEFORE UPDATE ON `irc_raw` FOR EACH ROW BEGIN
  SET NEW.irc_code            = fn_to_persian_digits(NEW.irc_code);
  SET NEW.mother_license_code = fn_to_persian_digits(NEW.mother_license_code);
  SET NEW.national_id_license      = fn_to_persian_digits(fn_digits_only_ascii(NEW.national_id_license));
  SET NEW.manufacturer_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.manufacturer_national_id));
  IF NEW.national_id_license IS NOT NULL AND NEW.national_id_license<>'' AND LENGTH(fn_digits_only_ascii(NEW.national_id_license)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی مالک پروانه باید ۱۱ رقم باشد.'; END IF;
  IF NEW.manufacturer_national_id IS NOT NULL AND NEW.manufacturer_national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.manufacturer_national_id)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی تولیدکننده باید ۱۱ رقم باشد.'; END IF;
  SET NEW.gtin = fn_norm_gtin(NEW.gtin);
  IF NEW.gtin IS NOT NULL AND NEW.gtin<>'' AND LENGTH(fn_digits_only_ascii(NEW.gtin)) NOT IN (8,12,13,14)
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='GTIN باید ۸/۱۲/۱۳/۱۴ رقم باشد.'; END IF;
  SET NEW.sent_datetime_raw             = fn_norm_date(NEW.sent_datetime_raw);
  SET NEW.final_fix_datetime_raw        = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.committee_datetime_raw        = fn_norm_date(NEW.committee_datetime_raw);
  SET NEW.committee_letter_datetime_raw = fn_norm_date(NEW.committee_letter_datetime_raw);
  SET NEW.first_issue_datetime_raw      = fn_norm_date(NEW.first_issue_datetime_raw);
  SET NEW.issue_datetime_raw            = fn_norm_date(NEW.issue_datetime_raw);
  SET NEW.expire_datetime_raw           = fn_norm_date(NEW.expire_datetime_raw);
  SET NEW.file_number              = fn_to_persian_digits(NEW.file_number);
  SET NEW.committee_letter_number  = fn_to_persian_digits(NEW.committee_letter_number);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `source_raw`
--

CREATE TABLE `source_raw` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `source_code` varchar(120) NOT NULL,
  `file_number` varchar(120) DEFAULT NULL,
  `company_name_fa` varchar(300) DEFAULT NULL,
  `company_national_id` varchar(32) NOT NULL,
  `production_site_name_fa` varchar(300) DEFAULT NULL,
  `production_site_country_fa` varchar(160) DEFAULT NULL,
  `production_site_type` varchar(160) DEFAULT NULL,
  `site_activity_type` varchar(160) DEFAULT NULL,
  `branch_name_fa` varchar(300) DEFAULT NULL,
  `branch_type` varchar(160) DEFAULT NULL,
  `production_line_name_fa` varchar(400) DEFAULT NULL,
  `production_line_type` varchar(160) DEFAULT NULL,
  `line_group_category` varchar(400) DEFAULT NULL,
  `group_category` varchar(200) DEFAULT NULL,
  `status_fa` varchar(120) DEFAULT NULL,
  `license_type_fa` varchar(160) DEFAULT NULL,
  `technical_committee_datetime_raw` varchar(10) DEFAULT NULL,
  `technical_committee_number` varchar(80) DEFAULT NULL,
  `request_register_datetime_raw` varchar(10) DEFAULT NULL,
  `final_fix_datetime_raw` varchar(10) DEFAULT NULL,
  `issue_datetime_raw` varchar(10) DEFAULT NULL,
  `expire_datetime_raw` varchar(10) DEFAULT NULL,
  `validity_duration_text` varchar(80) DEFAULT NULL,
  `review_duration_days` int(11) DEFAULT NULL,
  `university_name_fa` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `source_raw`
--
DELIMITER $$
CREATE TRIGGER `trg_source_raw_bi` BEFORE INSERT ON `source_raw` FOR EACH ROW BEGIN
  SET NEW.source_code   = fn_to_persian_digits(NEW.source_code);
  SET NEW.file_number   = fn_to_persian_digits(NEW.file_number);
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت منتصب باید ۱۱ رقم باشد.';
  END IF;
  SET NEW.technical_committee_number = fn_to_persian_digits(NEW.technical_committee_number);
  SET NEW.technical_committee_datetime_raw = fn_norm_date(NEW.technical_committee_datetime_raw);
  SET NEW.request_register_datetime_raw    = fn_norm_date(NEW.request_register_datetime_raw);
  SET NEW.final_fix_datetime_raw           = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.issue_datetime_raw               = fn_norm_date(NEW.issue_datetime_raw);
  SET NEW.expire_datetime_raw              = fn_norm_date(NEW.expire_datetime_raw);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_source_raw_bu` BEFORE UPDATE ON `source_raw` FOR EACH ROW BEGIN
  SET NEW.source_code   = fn_to_persian_digits(NEW.source_code);
  SET NEW.file_number   = fn_to_persian_digits(NEW.file_number);
  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت منتصب باید ۱۱ رقم باشد.';
  END IF;
  SET NEW.technical_committee_number = fn_to_persian_digits(NEW.technical_committee_number);
  SET NEW.technical_committee_datetime_raw = fn_norm_date(NEW.technical_committee_datetime_raw);
  SET NEW.request_register_datetime_raw    = fn_norm_date(NEW.request_register_datetime_raw);
  SET NEW.final_fix_datetime_raw           = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.issue_datetime_raw               = fn_norm_date(NEW.issue_datetime_raw);
  SET NEW.expire_datetime_raw              = fn_norm_date(NEW.expire_datetime_raw);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tech_raw`
--

CREATE TABLE `tech_raw` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `full_name_fa` varchar(300) NOT NULL,
  `father_name_fa` varchar(160) DEFAULT NULL,
  `gender_fa` varchar(50) DEFAULT NULL,
  `birth_certificate_no` varchar(50) DEFAULT NULL,
  `national_id` varchar(32) DEFAULT NULL,
  `birth_date_raw` varchar(10) DEFAULT NULL,
  `birth_place_fa` varchar(160) DEFAULT NULL,
  `birth_certificate_place_fa` varchar(160) DEFAULT NULL,
  `mobile_phone` varchar(20) DEFAULT NULL,
  `phone_landline` varchar(20) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `degree_fa` varchar(160) DEFAULT NULL,
  `major_fa` varchar(160) DEFAULT NULL,
  `specialty_fa` varchar(160) DEFAULT NULL,
  `education_university_name_fa` varchar(300) DEFAULT NULL,
  `company_name_fa` varchar(300) DEFAULT NULL,
  `company_national_id` varchar(32) DEFAULT NULL,
  `shift_name` varchar(80) DEFAULT NULL,
  `supervised_lines_fa` text DEFAULT NULL,
  `process_type_fa` varchar(160) DEFAULT NULL,
  `domain_fa` varchar(120) DEFAULT NULL,
  `license_number` varchar(120) DEFAULT NULL,
  `license_start_date_raw` varchar(10) DEFAULT NULL,
  `ttac_expire_raw` varchar(10) DEFAULT NULL,
  `has_physical_card` tinyint(4) DEFAULT NULL,
  `source_licenses_fa` text DEFAULT NULL,
  `physical_card_letter_number` varchar(120) DEFAULT NULL,
  `physical_card_letter_datetime_raw` varchar(10) DEFAULT NULL,
  `request_register_datetime_raw` varchar(10) DEFAULT NULL,
  `final_fix_datetime_raw` varchar(10) DEFAULT NULL,
  `committee_datetime_raw` varchar(10) DEFAULT NULL,
  `committee_letter_number` varchar(120) DEFAULT NULL,
  `committee_letter_datetime_raw` varchar(10) DEFAULT NULL,
  `serial_number_fa` varchar(120) DEFAULT NULL,
  `serial_date_raw` varchar(10) DEFAULT NULL,
  `validity_duration_text` varchar(80) DEFAULT NULL,
  `review_first_action_duration_text` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `tech_raw`
--
DELIMITER $$
CREATE TRIGGER `trg_tech_raw_bi` BEFORE INSERT ON `tech_raw` FOR EACH ROW BEGIN
  SET NEW.national_id   = fn_to_persian_digits(fn_digits_only_ascii(NEW.national_id));
  IF NEW.national_id IS NOT NULL AND NEW.national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.national_id)) <> 10
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='کد ملی شخص حقیقی باید ۱۰ رقم باشد.'; END IF;

  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF NEW.company_national_id IS NOT NULL AND NEW.company_national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت منتصب باید ۱۱ رقم باشد.'; END IF;

  SET NEW.mobile_phone = fn_norm_mobile_ir(NEW.mobile_phone);
  IF NEW.mobile_phone IS NOT NULL AND NEW.mobile_phone<>'' AND LENGTH(fn_digits_only_ascii(NEW.mobile_phone)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود.'; END IF;

  SET NEW.birth_date_raw                  = fn_norm_date(NEW.birth_date_raw);
  SET NEW.license_start_date_raw          = fn_norm_date(NEW.license_start_date_raw);
  SET NEW.ttac_expire_raw                 = fn_norm_date(NEW.ttac_expire_raw);
  SET NEW.request_register_datetime_raw   = fn_norm_date(NEW.request_register_datetime_raw);
  SET NEW.final_fix_datetime_raw          = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.committee_datetime_raw          = fn_norm_date(NEW.committee_datetime_raw);
  SET NEW.committee_letter_datetime_raw   = fn_norm_date(NEW.committee_letter_datetime_raw);
  SET NEW.physical_card_letter_datetime_raw = fn_norm_date(NEW.physical_card_letter_datetime_raw);
  SET NEW.serial_date_raw                 = fn_norm_date(NEW.serial_date_raw);

  SET NEW.birth_certificate_no            = fn_to_persian_digits(NEW.birth_certificate_no);
  SET NEW.license_number                  = fn_to_persian_digits(NEW.license_number);
  SET NEW.physical_card_letter_number     = fn_to_persian_digits(NEW.physical_card_letter_number);
  SET NEW.serial_number_fa                = fn_to_persian_digits(NEW.serial_number_fa);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_tech_raw_bu` BEFORE UPDATE ON `tech_raw` FOR EACH ROW BEGIN
  SET NEW.national_id   = fn_to_persian_digits(fn_digits_only_ascii(NEW.national_id));
  IF NEW.national_id IS NOT NULL AND NEW.national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.national_id)) <> 10
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='کد ملی شخص حقیقی باید ۱۰ رقم باشد.'; END IF;

  SET NEW.company_national_id = fn_to_persian_digits(fn_digits_only_ascii(NEW.company_national_id));
  IF NEW.company_national_id IS NOT NULL AND NEW.company_national_id<>'' AND LENGTH(fn_digits_only_ascii(NEW.company_national_id)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شناسه ملی شرکت منتصب باید ۱۱ رقم باشد.'; END IF;

  SET NEW.mobile_phone = fn_norm_mobile_ir(NEW.mobile_phone);
  IF NEW.mobile_phone IS NOT NULL AND NEW.mobile_phone<>'' AND LENGTH(fn_digits_only_ascii(NEW.mobile_phone)) <> 11
     THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود.'; END IF;

  SET NEW.birth_date_raw                  = fn_norm_date(NEW.birth_date_raw);
  SET NEW.license_start_date_raw          = fn_norm_date(NEW.license_start_date_raw);
  SET NEW.ttac_expire_raw                 = fn_norm_date(NEW.ttac_expire_raw);
  SET NEW.request_register_datetime_raw   = fn_norm_date(NEW.request_register_datetime_raw);
  SET NEW.final_fix_datetime_raw          = fn_norm_date(NEW.final_fix_datetime_raw);
  SET NEW.committee_datetime_raw          = fn_norm_date(NEW.committee_datetime_raw);
  SET NEW.committee_letter_datetime_raw   = fn_norm_date(NEW.committee_letter_datetime_raw);
  SET NEW.physical_card_letter_datetime_raw = fn_norm_date(NEW.physical_card_letter_datetime_raw);
  SET NEW.serial_date_raw                 = fn_norm_date(NEW.serial_date_raw);

  SET NEW.birth_certificate_no            = fn_to_persian_digits(NEW.birth_certificate_no);
  SET NEW.license_number                  = fn_to_persian_digits(NEW.license_number);
  SET NEW.physical_card_letter_number     = fn_to_persian_digits(NEW.physical_card_letter_number);
  SET NEW.serial_number_fa                = fn_to_persian_digits(NEW.serial_number_fa);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_irc_final_bi`
-- (See below for the actual view)
--
CREATE TABLE `v_irc_final_bi` (
`ردیف` bigint(20) unsigned
,`IRC` text
,`کد پروانه مادری` text
,`شماره پرونده` varchar(120)
,`وضعیت` varchar(120)
,`نام فرآورده` varchar(400)
,`نام تجاری` varchar(400)
,`GTIN` varchar(32)
,`شناسه گروه دسته` varchar(120)
,`حوزه` varchar(120)
,`نوع واحد` varchar(160)
,`نام مالک پروانه` varchar(300)
,`شناسه ملی مالک پروانه` varchar(32)
,`تولیدکننده` varchar(300)
,`شناسه ملی تولیدکننده` varchar(32)
,`کشور تولیدکننده` varchar(160)
,`شماره نامه کمیته` varchar(120)
,`تاریخ کمیته` varchar(10)
,`تاریخ نامه کمیته` varchar(10)
,`تاریخ ارسال` varchar(10)
,`تاریخ رفع نقص نهایی` varchar(10)
,`تاریخ اولین صدور` varchar(10)
,`تاریخ صدور` varchar(10)
,`تاریخ انقضا` varchar(10)
,`row_id_en` bigint(20) unsigned
,`irc_en` text
,`mother_license_code_en` text
,`file_number_en` varchar(120)
,`status_fa_en` varchar(120)
,`product_generic_name_fa_en` varchar(400)
,`product_trade_name_fa_en` varchar(400)
,`gtin_en` varchar(32)
,`category_group_code_en` varchar(120)
,`domain_fa_en` varchar(120)
,`unit_type_fa_en` varchar(160)
,`license_holder_name_fa_en` varchar(300)
,`national_id_license_en` varchar(32)
,`manufacturer_name_fa_en` varchar(300)
,`manufacturer_national_id_en` varchar(32)
,`manufacturer_country_fa_en` varchar(160)
,`committee_letter_number_en` varchar(120)
,`committee_datetime_raw_en` varchar(10)
,`committee_letter_datetime_raw_en` varchar(10)
,`sent_datetime_raw_en` varchar(10)
,`final_fix_datetime_raw_en` varchar(10)
,`first_issue_datetime_raw_en` varchar(10)
,`issue_datetime_raw_en` varchar(10)
,`expire_datetime_raw_en` varchar(10)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_source_final_bi`
-- (See below for the actual view)
--
CREATE TABLE `v_source_final_bi` (
`ردیف` bigint(20) unsigned
,`کد منبع` varchar(120)
,`شماره پرونده` varchar(120)
,`وضعیت` varchar(120)
,`نوع پروانه (اختیاری)` varchar(160)
,`مدت اعتبار` varchar(80)
,`مدت زمان بررسی` int(11)
,`نام فارسی سایت تولیدی` varchar(300)
,`نام شرکت منتصب` varchar(300)
,`شناسه ملی شرکت منتصب` varchar(32)
,`نام کشور سایت تولیدی` varchar(160)
,`نوع سایت تولیدی` varchar(160)
,`نوع فعالیت های سایت` varchar(160)
,`نام فارسی شعبه` varchar(300)
,`نوع شعبه` varchar(160)
,`نام فارسی خط تولید` varchar(400)
,`نوع خط تولید` varchar(160)
,`گروه و دسته مرتبط با خط` varchar(400)
,`گروه و دسته مرتبط با منبع` varchar(200)
,`تاریخ کمیته فنی` varchar(10)
,`شماره کمیته فنی` varchar(80)
,`تاریخ ثبت درخواست` varchar(10)
,`تاریخ رفع نقص نهایی` varchar(10)
,`تاریخ صدور` varchar(10)
,`تاریخ انقضا` varchar(10)
,`نام دانشگاه` varchar(300)
,`row_id_en` bigint(20) unsigned
,`source_code_en` varchar(120)
,`file_number_en` varchar(120)
,`status_fa_en` varchar(120)
,`license_type_fa_en` varchar(160)
,`validity_duration_text_en` varchar(80)
,`review_duration_days_en` int(11)
,`production_site_name_fa_en` varchar(300)
,`company_name_fa_en` varchar(300)
,`company_national_id_en` varchar(32)
,`production_site_country_fa_en` varchar(160)
,`production_site_type_en` varchar(160)
,`site_activity_type_en` varchar(160)
,`branch_name_fa_en` varchar(300)
,`branch_type_en` varchar(160)
,`production_line_name_fa_en` varchar(400)
,`production_line_type_en` varchar(160)
,`line_group_category_en` varchar(400)
,`group_category_en` varchar(200)
,`technical_committee_datetime_raw_en` varchar(10)
,`technical_committee_number_en` varchar(80)
,`request_register_datetime_raw_en` varchar(10)
,`final_fix_datetime_raw_en` varchar(10)
,`issue_datetime_raw_en` varchar(10)
,`expire_datetime_raw_en` varchar(10)
,`university_name_fa_en` varchar(300)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_tech_final_bi`
-- (See below for the actual view)
--
CREATE TABLE `v_tech_final_bi` (
`ردیف` bigint(20) unsigned
,`نام و نام خانوادگی` varchar(300)
,`نام پدر` varchar(160)
,`جنسیت` varchar(50)
,`شماره شناسنامه` varchar(50)
,`کد ملی` varchar(32)
,`تاریخ تولد` varchar(10)
,`محل تولد` varchar(160)
,`محل صدور شناسنامه` varchar(160)
,`شماره همراه` varchar(20)
,`تلفن ثابت` varchar(20)
,`ایمیل` varchar(200)
,`مدرک تحصیلی` varchar(160)
,`رشته تحصیلی` varchar(160)
,`گرایش تحصیلی` varchar(160)
,`دانشگاه محل تحصیل` varchar(300)
,`نام شرکت منتصب` varchar(300)
,`شناسه ملی شرکت منتصب` varchar(32)
,`شیفت کاری` varchar(80)
,`خطوط تحت نظارت` text
,`نوع فرآیند` varchar(160)
,`حوزه` varchar(120)
,`شماره پروانه` varchar(120)
,`تاریخ شروع پروانه` varchar(10)
,`تاریخ اعتبار پروانه` varchar(10)
,`کارت فیزیکی` tinyint(4)
,`پروانه‌های ثبت منبع` text
,`شماره نامه کارت فیزیکی` varchar(120)
,`تاریخ نامه کارت فیزیکی` varchar(10)
,`تاریخ ثبت درخواست` varchar(10)
,`تاریخ رفع نقص نهایی` varchar(10)
,`تاریخ کمیته` varchar(10)
,`شماره نامه کمیته` varchar(120)
,`تاریخ نامه کمیته` varchar(10)
,`شماره نامه ارسالی به سازمان` varchar(120)
,`تاریخ نامه ارسالی به سازمان` varchar(10)
,`مدت اعتبار` varchar(80)
,`مدت زمان بررسی و اولین اقدام` varchar(120)
,`row_id_en` bigint(20) unsigned
,`full_name_fa_en` varchar(300)
,`father_name_fa_en` varchar(160)
,`gender_fa_en` varchar(50)
,`birth_certificate_no_en` varchar(50)
,`national_id_en` varchar(32)
,`birth_date_raw_en` varchar(10)
,`birth_place_fa_en` varchar(160)
,`birth_certificate_place_fa_en` varchar(160)
,`mobile_phone_en` varchar(20)
,`phone_landline_en` varchar(20)
,`email_en` varchar(200)
,`degree_fa_en` varchar(160)
,`major_fa_en` varchar(160)
,`specialty_fa_en` varchar(160)
,`education_university_name_fa_en` varchar(300)
,`company_name_fa_en` varchar(300)
,`company_national_id_en` varchar(32)
,`shift_name_en` varchar(80)
,`supervised_lines_fa_en` text
,`process_type_fa_en` varchar(160)
,`domain_fa_en` varchar(120)
,`license_number_en` varchar(120)
,`license_start_date_raw_en` varchar(10)
,`ttac_expire_raw_en` varchar(10)
,`has_physical_card_en` tinyint(4)
,`source_licenses_fa_en` text
,`physical_card_letter_number_en` varchar(120)
,`physical_card_letter_datetime_raw_en` varchar(10)
,`request_register_datetime_raw_en` varchar(10)
,`final_fix_datetime_raw_en` varchar(10)
,`committee_datetime_raw_en` varchar(10)
,`committee_letter_number_en` varchar(120)
,`committee_letter_datetime_raw_en` varchar(10)
,`serial_number_fa_en` varchar(120)
,`serial_date_raw_en` varchar(10)
,`validity_duration_text_en` varchar(80)
,`review_first_action_duration_text_en` varchar(120)
);

-- --------------------------------------------------------

--
-- Structure for view `v_irc_final_bi`
--
DROP TABLE IF EXISTS `v_irc_final_bi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`kancir`@`localhost` SQL SECURITY DEFINER VIEW `v_irc_final_bi`  AS SELECT `r`.`id` AS `ردیف`, `r`.`irc_code` AS `IRC`, `r`.`mother_license_code` AS `کد پروانه مادری`, `r`.`file_number` AS `شماره پرونده`, `r`.`status_fa` AS `وضعیت`, `r`.`product_generic_name_fa` AS `نام فرآورده`, `r`.`product_trade_name_fa` AS `نام تجاری`, `r`.`gtin` AS `GTIN`, `r`.`category_group_code` AS `شناسه گروه دسته`, `r`.`domain_fa` AS `حوزه`, `r`.`unit_type_fa` AS `نوع واحد`, `r`.`license_holder_name_fa` AS `نام مالک پروانه`, `r`.`national_id_license` AS `شناسه ملی مالک پروانه`, `r`.`manufacturer_name_fa` AS `تولیدکننده`, `r`.`manufacturer_national_id` AS `شناسه ملی تولیدکننده`, `r`.`manufacturer_country_fa` AS `کشور تولیدکننده`, `r`.`committee_letter_number` AS `شماره نامه کمیته`, `r`.`committee_datetime_raw` AS `تاریخ کمیته`, `r`.`committee_letter_datetime_raw` AS `تاریخ نامه کمیته`, `r`.`sent_datetime_raw` AS `تاریخ ارسال`, `r`.`final_fix_datetime_raw` AS `تاریخ رفع نقص نهایی`, `r`.`first_issue_datetime_raw` AS `تاریخ اولین صدور`, `r`.`issue_datetime_raw` AS `تاریخ صدور`, `r`.`expire_datetime_raw` AS `تاریخ انقضا`, `r`.`id` AS `row_id_en`, `r`.`irc_code` AS `irc_en`, `r`.`mother_license_code` AS `mother_license_code_en`, `r`.`file_number` AS `file_number_en`, `r`.`status_fa` AS `status_fa_en`, `r`.`product_generic_name_fa` AS `product_generic_name_fa_en`, `r`.`product_trade_name_fa` AS `product_trade_name_fa_en`, `r`.`gtin` AS `gtin_en`, `r`.`category_group_code` AS `category_group_code_en`, `r`.`domain_fa` AS `domain_fa_en`, `r`.`unit_type_fa` AS `unit_type_fa_en`, `r`.`license_holder_name_fa` AS `license_holder_name_fa_en`, `r`.`national_id_license` AS `national_id_license_en`, `r`.`manufacturer_name_fa` AS `manufacturer_name_fa_en`, `r`.`manufacturer_national_id` AS `manufacturer_national_id_en`, `r`.`manufacturer_country_fa` AS `manufacturer_country_fa_en`, `r`.`committee_letter_number` AS `committee_letter_number_en`, `r`.`committee_datetime_raw` AS `committee_datetime_raw_en`, `r`.`committee_letter_datetime_raw` AS `committee_letter_datetime_raw_en`, `r`.`sent_datetime_raw` AS `sent_datetime_raw_en`, `r`.`final_fix_datetime_raw` AS `final_fix_datetime_raw_en`, `r`.`first_issue_datetime_raw` AS `first_issue_datetime_raw_en`, `r`.`issue_datetime_raw` AS `issue_datetime_raw_en`, `r`.`expire_datetime_raw` AS `expire_datetime_raw_en` FROM `irc_raw` AS `r` ;

-- --------------------------------------------------------

--
-- Structure for view `v_source_final_bi`
--
DROP TABLE IF EXISTS `v_source_final_bi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`kancir`@`localhost` SQL SECURITY DEFINER VIEW `v_source_final_bi`  AS SELECT `s`.`id` AS `ردیف`, `s`.`source_code` AS `کد منبع`, `s`.`file_number` AS `شماره پرونده`, `s`.`status_fa` AS `وضعیت`, `s`.`license_type_fa` AS `نوع پروانه (اختیاری)`, `s`.`validity_duration_text` AS `مدت اعتبار`, `s`.`review_duration_days` AS `مدت زمان بررسی`, `s`.`production_site_name_fa` AS `نام فارسی سایت تولیدی`, `s`.`company_name_fa` AS `نام شرکت منتصب`, `s`.`company_national_id` AS `شناسه ملی شرکت منتصب`, `s`.`production_site_country_fa` AS `نام کشور سایت تولیدی`, `s`.`production_site_type` AS `نوع سایت تولیدی`, `s`.`site_activity_type` AS `نوع فعالیت های سایت`, `s`.`branch_name_fa` AS `نام فارسی شعبه`, `s`.`branch_type` AS `نوع شعبه`, `s`.`production_line_name_fa` AS `نام فارسی خط تولید`, `s`.`production_line_type` AS `نوع خط تولید`, `s`.`line_group_category` AS `گروه و دسته مرتبط با خط`, `s`.`group_category` AS `گروه و دسته مرتبط با منبع`, `s`.`technical_committee_datetime_raw` AS `تاریخ کمیته فنی`, `s`.`technical_committee_number` AS `شماره کمیته فنی`, `s`.`request_register_datetime_raw` AS `تاریخ ثبت درخواست`, `s`.`final_fix_datetime_raw` AS `تاریخ رفع نقص نهایی`, `s`.`issue_datetime_raw` AS `تاریخ صدور`, `s`.`expire_datetime_raw` AS `تاریخ انقضا`, `s`.`university_name_fa` AS `نام دانشگاه`, `s`.`id` AS `row_id_en`, `s`.`source_code` AS `source_code_en`, `s`.`file_number` AS `file_number_en`, `s`.`status_fa` AS `status_fa_en`, `s`.`license_type_fa` AS `license_type_fa_en`, `s`.`validity_duration_text` AS `validity_duration_text_en`, `s`.`review_duration_days` AS `review_duration_days_en`, `s`.`production_site_name_fa` AS `production_site_name_fa_en`, `s`.`company_name_fa` AS `company_name_fa_en`, `s`.`company_national_id` AS `company_national_id_en`, `s`.`production_site_country_fa` AS `production_site_country_fa_en`, `s`.`production_site_type` AS `production_site_type_en`, `s`.`site_activity_type` AS `site_activity_type_en`, `s`.`branch_name_fa` AS `branch_name_fa_en`, `s`.`branch_type` AS `branch_type_en`, `s`.`production_line_name_fa` AS `production_line_name_fa_en`, `s`.`production_line_type` AS `production_line_type_en`, `s`.`line_group_category` AS `line_group_category_en`, `s`.`group_category` AS `group_category_en`, `s`.`technical_committee_datetime_raw` AS `technical_committee_datetime_raw_en`, `s`.`technical_committee_number` AS `technical_committee_number_en`, `s`.`request_register_datetime_raw` AS `request_register_datetime_raw_en`, `s`.`final_fix_datetime_raw` AS `final_fix_datetime_raw_en`, `s`.`issue_datetime_raw` AS `issue_datetime_raw_en`, `s`.`expire_datetime_raw` AS `expire_datetime_raw_en`, `s`.`university_name_fa` AS `university_name_fa_en` FROM `source_raw` AS `s` ;

-- --------------------------------------------------------

--
-- Structure for view `v_tech_final_bi`
--
DROP TABLE IF EXISTS `v_tech_final_bi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`kancir`@`localhost` SQL SECURITY DEFINER VIEW `v_tech_final_bi`  AS SELECT `t`.`id` AS `ردیف`, `t`.`full_name_fa` AS `نام و نام خانوادگی`, `t`.`father_name_fa` AS `نام پدر`, `t`.`gender_fa` AS `جنسیت`, `t`.`birth_certificate_no` AS `شماره شناسنامه`, `t`.`national_id` AS `کد ملی`, `t`.`birth_date_raw` AS `تاریخ تولد`, `t`.`birth_place_fa` AS `محل تولد`, `t`.`birth_certificate_place_fa` AS `محل صدور شناسنامه`, `t`.`mobile_phone` AS `شماره همراه`, `t`.`phone_landline` AS `تلفن ثابت`, `t`.`email` AS `ایمیل`, `t`.`degree_fa` AS `مدرک تحصیلی`, `t`.`major_fa` AS `رشته تحصیلی`, `t`.`specialty_fa` AS `گرایش تحصیلی`, `t`.`education_university_name_fa` AS `دانشگاه محل تحصیل`, `t`.`company_name_fa` AS `نام شرکت منتصب`, `t`.`company_national_id` AS `شناسه ملی شرکت منتصب`, `t`.`shift_name` AS `شیفت کاری`, `t`.`supervised_lines_fa` AS `خطوط تحت نظارت`, `t`.`process_type_fa` AS `نوع فرآیند`, `t`.`domain_fa` AS `حوزه`, `t`.`license_number` AS `شماره پروانه`, `t`.`license_start_date_raw` AS `تاریخ شروع پروانه`, `t`.`ttac_expire_raw` AS `تاریخ اعتبار پروانه`, `t`.`has_physical_card` AS `کارت فیزیکی`, `t`.`source_licenses_fa` AS `پروانه‌های ثبت منبع`, `t`.`physical_card_letter_number` AS `شماره نامه کارت فیزیکی`, `t`.`physical_card_letter_datetime_raw` AS `تاریخ نامه کارت فیزیکی`, `t`.`request_register_datetime_raw` AS `تاریخ ثبت درخواست`, `t`.`final_fix_datetime_raw` AS `تاریخ رفع نقص نهایی`, `t`.`committee_datetime_raw` AS `تاریخ کمیته`, `t`.`committee_letter_number` AS `شماره نامه کمیته`, `t`.`committee_letter_datetime_raw` AS `تاریخ نامه کمیته`, `t`.`serial_number_fa` AS `شماره نامه ارسالی به سازمان`, `t`.`serial_date_raw` AS `تاریخ نامه ارسالی به سازمان`, `t`.`validity_duration_text` AS `مدت اعتبار`, `t`.`review_first_action_duration_text` AS `مدت زمان بررسی و اولین اقدام`, `t`.`id` AS `row_id_en`, `t`.`full_name_fa` AS `full_name_fa_en`, `t`.`father_name_fa` AS `father_name_fa_en`, `t`.`gender_fa` AS `gender_fa_en`, `t`.`birth_certificate_no` AS `birth_certificate_no_en`, `t`.`national_id` AS `national_id_en`, `t`.`birth_date_raw` AS `birth_date_raw_en`, `t`.`birth_place_fa` AS `birth_place_fa_en`, `t`.`birth_certificate_place_fa` AS `birth_certificate_place_fa_en`, `t`.`mobile_phone` AS `mobile_phone_en`, `t`.`phone_landline` AS `phone_landline_en`, `t`.`email` AS `email_en`, `t`.`degree_fa` AS `degree_fa_en`, `t`.`major_fa` AS `major_fa_en`, `t`.`specialty_fa` AS `specialty_fa_en`, `t`.`education_university_name_fa` AS `education_university_name_fa_en`, `t`.`company_name_fa` AS `company_name_fa_en`, `t`.`company_national_id` AS `company_national_id_en`, `t`.`shift_name` AS `shift_name_en`, `t`.`supervised_lines_fa` AS `supervised_lines_fa_en`, `t`.`process_type_fa` AS `process_type_fa_en`, `t`.`domain_fa` AS `domain_fa_en`, `t`.`license_number` AS `license_number_en`, `t`.`license_start_date_raw` AS `license_start_date_raw_en`, `t`.`ttac_expire_raw` AS `ttac_expire_raw_en`, `t`.`has_physical_card` AS `has_physical_card_en`, `t`.`source_licenses_fa` AS `source_licenses_fa_en`, `t`.`physical_card_letter_number` AS `physical_card_letter_number_en`, `t`.`physical_card_letter_datetime_raw` AS `physical_card_letter_datetime_raw_en`, `t`.`request_register_datetime_raw` AS `request_register_datetime_raw_en`, `t`.`final_fix_datetime_raw` AS `final_fix_datetime_raw_en`, `t`.`committee_datetime_raw` AS `committee_datetime_raw_en`, `t`.`committee_letter_number` AS `committee_letter_number_en`, `t`.`committee_letter_datetime_raw` AS `committee_letter_datetime_raw_en`, `t`.`serial_number_fa` AS `serial_number_fa_en`, `t`.`serial_date_raw` AS `serial_date_raw_en`, `t`.`validity_duration_text` AS `validity_duration_text_en`, `t`.`review_first_action_duration_text` AS `review_first_action_duration_text_en` FROM `tech_raw` AS `t` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `app_users`
--
ALTER TABLE `app_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_app_users_username` (`username`);

--
-- Indexes for table `factories_raw`
--
ALTER TABLE `factories_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_factories_company_nid` (`company_national_id`);

--
-- Indexes for table `factories_whitelist`
--
ALTER TABLE `factories_whitelist`
  ADD PRIMARY KEY (`company_national_id`);

--
-- Indexes for table `irc_raw`
--
ALTER TABLE `irc_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_irc_code_sha256` (`irc_code_sha256`),
  ADD KEY `idx_mother_license_sha256` (`mother_license_code_sha256`),
  ADD KEY `idx_irc_owner_nid` (`national_id_license`),
  ADD KEY `idx_irc_manu_nid` (`manufacturer_national_id`);

--
-- Indexes for table `source_raw`
--
ALTER TABLE `source_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_source_code` (`source_code`),
  ADD KEY `idx_source_company_nid` (`company_national_id`);

--
-- Indexes for table `tech_raw`
--
ALTER TABLE `tech_raw`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tech_company_nid` (`company_national_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `app_users`
--
ALTER TABLE `app_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `factories_raw`
--
ALTER TABLE `factories_raw`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `irc_raw`
--
ALTER TABLE `irc_raw`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `source_raw`
--
ALTER TABLE `source_raw`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tech_raw`
--
ALTER TABLE `tech_raw`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `factories_raw`
--
ALTER TABLE `factories_raw`
  ADD CONSTRAINT `fk_factories_raw_whitelist` FOREIGN KEY (`company_national_id`) REFERENCES `factories_whitelist` (`company_national_id`) ON UPDATE CASCADE;

--
-- Constraints for table `irc_raw`
--
ALTER TABLE `irc_raw`
  ADD CONSTRAINT `fk_irc_manu_factories` FOREIGN KEY (`manufacturer_national_id`) REFERENCES `factories_raw` (`company_national_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_irc_owner_factories` FOREIGN KEY (`national_id_license`) REFERENCES `factories_raw` (`company_national_id`) ON UPDATE CASCADE;

--
-- Constraints for table `source_raw`
--
ALTER TABLE `source_raw`
  ADD CONSTRAINT `fk_source_company_factories` FOREIGN KEY (`company_national_id`) REFERENCES `factories_raw` (`company_national_id`) ON UPDATE CASCADE;

--
-- Constraints for table `tech_raw`
--
ALTER TABLE `tech_raw`
  ADD CONSTRAINT `fk_tech_company_factories` FOREIGN KEY (`company_national_id`) REFERENCES `factories_raw` (`company_national_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
