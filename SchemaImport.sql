CREATE DATABASE  IF NOT EXISTS `buymerealtest` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `buymerealtest`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: buymerealtest
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `AID` int NOT NULL,
  `Password` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`AID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alertsets`
--

DROP TABLE IF EXISTS `alertsets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alertsets` (
  `Alert_ID` int NOT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `DateCreated` date NOT NULL DEFAULT (curdate()),
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Alert_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `alertsets_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertsets`
--

LOCK TABLES `alertsets` WRITE;
/*!40000 ALTER TABLE `alertsets` DISABLE KEYS */;
/*!40000 ALTER TABLE `alertsets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `answers` (
  `Q_ID` int NOT NULL,
  `CRID` int NOT NULL,
  PRIMARY KEY (`Q_ID`),
  KEY `CRID` (`CRID`),
  CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`Q_ID`) REFERENCES `questionasks` (`Q_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answers`
--

LOCK TABLES `answers` WRITE;
/*!40000 ALTER TABLE `answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction`
--

DROP TABLE IF EXISTS `auction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction` (
  `A_ID` int NOT NULL,
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Price` float NOT NULL,
  `CloseDate` date NOT NULL,
  `CloseTime` date NOT NULL,
  `Closed` tinyint(1) NOT NULL DEFAULT '0',
  `Subcategory` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `SubAttribute` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`A_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction`
--

LOCK TABLES `auction` WRITE;
/*!40000 ALTER TABLE `auction` DISABLE KEYS */;
/*!40000 ALTER TABLE `auction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autobid`
--

DROP TABLE IF EXISTS `autobid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `autobid` (
  `BID_ID` int NOT NULL,
  `Increment` float NOT NULL,
  `Buy_Limit` int NOT NULL,
  `Current` float NOT NULL,
  PRIMARY KEY (`BID_ID`),
  CONSTRAINT `autobid_ibfk_1` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autobid`
--

LOCK TABLES `autobid` WRITE;
/*!40000 ALTER TABLE `autobid` DISABLE KEYS */;
/*!40000 ALTER TABLE `autobid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bids` (
  `BID_ID` int NOT NULL,
  `Price` float NOT NULL,
  `Time` date NOT NULL,
  PRIMARY KEY (`BID_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
/*!40000 ALTER TABLE `bids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids_on`
--

DROP TABLE IF EXISTS `bids_on`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bids_on` (
  `BID_ID` int NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`BID_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `bids_on_ibfk_1` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bids_on_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids_on`
--

LOCK TABLES `bids_on` WRITE;
/*!40000 ALTER TABLE `bids_on` DISABLE KEYS */;
/*!40000 ALTER TABLE `bids_on` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_rep_create`
--

DROP TABLE IF EXISTS `customer_rep_create`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_rep_create` (
  `CRID` int NOT NULL,
  `Password` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AID` int NOT NULL,
  PRIMARY KEY (`CRID`),
  KEY `AID` (`AID`),
  CONSTRAINT `customer_rep_create_ibfk_1` FOREIGN KEY (`AID`) REFERENCES `admin` (`AID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_rep_create`
--

LOCK TABLES `customer_rep_create` WRITE;
/*!40000 ALTER TABLE `customer_rep_create` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_rep_create` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deletes`
--

DROP TABLE IF EXISTS `deletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deletes` (
  `CRID` int NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`CRID`,`A_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `deletes_ibfk_1` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `deletes_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deletes`
--

LOCK TABLES `deletes` WRITE;
/*!40000 ALTER TABLE `deletes` DISABLE KEYS */;
/*!40000 ALTER TABLE `deletes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `end_user`
--

DROP TABLE IF EXISTS `end_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `end_user` (
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Password` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `end_user`
--

LOCK TABLES `end_user` WRITE;
/*!40000 ALTER TABLE `end_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `end_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generates_sales_report`
--

DROP TABLE IF EXISTS `generates_sales_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `generates_sales_report` (
  `AID` int NOT NULL,
  `Sale_ID` int NOT NULL,
  PRIMARY KEY (`AID`,`Sale_ID`),
  KEY `Sale_ID` (`Sale_ID`),
  CONSTRAINT `generates_sales_report_ibfk_1` FOREIGN KEY (`AID`) REFERENCES `admin` (`AID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `generates_sales_report_ibfk_2` FOREIGN KEY (`Sale_ID`) REFERENCES `sale` (`Sale_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generates_sales_report`
--

LOCK TABLES `generates_sales_report` WRITE;
/*!40000 ALTER TABLE `generates_sales_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `generates_sales_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manages`
--

DROP TABLE IF EXISTS `manages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manages` (
  `Username_DeleteAcc` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Username_CreateAcc` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Username_DeleteAcc`,`Username_CreateAcc`),
  KEY `Username_CreateAcc` (`Username_CreateAcc`),
  CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`Username_DeleteAcc`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `manages_ibfk_2` FOREIGN KEY (`Username_CreateAcc`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manages`
--

LOCK TABLES `manages` WRITE;
/*!40000 ALTER TABLE `manages` DISABLE KEYS */;
/*!40000 ALTER TABLE `manages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manualbid`
--

DROP TABLE IF EXISTS `manualbid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manualbid` (
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`BID_ID`),
  CONSTRAINT `manualbid_ibfk_1` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manualbid`
--

LOCK TABLES `manualbid` WRITE;
/*!40000 ALTER TABLE `manualbid` DISABLE KEYS */;
/*!40000 ALTER TABLE `manualbid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places`
--

DROP TABLE IF EXISTS `places`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `places` (
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`BID_ID`),
  KEY `BID_ID` (`BID_ID`),
  CONSTRAINT `places_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `places_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places`
--

LOCK TABLES `places` WRITE;
/*!40000 ALTER TABLE `places` DISABLE KEYS */;
/*!40000 ALTER TABLE `places` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `PostDate` date NOT NULL,
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`A_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionasks`
--

DROP TABLE IF EXISTS `questionasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `questionasks` (
  `Q_ID` int NOT NULL,
  `Q_Text` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Q_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `questionasks_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questionasks`
--

LOCK TABLES `questionasks` WRITE;
/*!40000 ALTER TABLE `questionasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `questionasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `removes`
--

DROP TABLE IF EXISTS `removes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `removes` (
  `CRID` int NOT NULL,
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`CRID`,`BID_ID`),
  KEY `BID_ID` (`BID_ID`),
  CONSTRAINT `removes_ibfk_1` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `removes_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `removes`
--

LOCK TABLES `removes` WRITE;
/*!40000 ALTER TABLE `removes` DISABLE KEYS */;
/*!40000 ALTER TABLE `removes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resets_pass`
--

DROP TABLE IF EXISTS `resets_pass`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resets_pass` (
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CRID` int NOT NULL,
  PRIMARY KEY (`Username`),
  KEY `CRID` (`CRID`),
  CONSTRAINT `resets_pass_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `resets_pass_ibfk_2` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resets_pass`
--

LOCK TABLES `resets_pass` WRITE;
/*!40000 ALTER TABLE `resets_pass` DISABLE KEYS */;
/*!40000 ALTER TABLE `resets_pass` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale`
--

DROP TABLE IF EXISTS `sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale` (
  `Sale_ID` int NOT NULL,
  `A_ID` int NOT NULL,
  `Date` date NOT NULL,
  `Amount` float NOT NULL,
  PRIMARY KEY (`Sale_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale`
--

LOCK TABLES `sale` WRITE;
/*!40000 ALTER TABLE `sale` DISABLE KEYS */;
/*!40000 ALTER TABLE `sale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `searches`
--

DROP TABLE IF EXISTS `searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `searches` (
  `Min_Price` float DEFAULT NULL,
  `Max_Price` float DEFAULT NULL,
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`A_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `searches_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `searches_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `searches`
--

LOCK TABLES `searches` WRITE;
/*!40000 ALTER TABLE `searches` DISABLE KEYS */;
/*!40000 ALTER TABLE `searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `views_previous`
--

DROP TABLE IF EXISTS `views_previous`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `views_previous` (
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`BID_ID`),
  KEY `BID_ID` (`BID_ID`),
  CONSTRAINT `views_previous_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `views_previous_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `views_previous`
--

LOCK TABLES `views_previous` WRITE;
/*!40000 ALTER TABLE `views_previous` DISABLE KEYS */;
/*!40000 ALTER TABLE `views_previous` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `watches`
--

DROP TABLE IF EXISTS `watches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `watches` (
  `Alert_ID` int NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`Alert_ID`,`A_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `watches_ibfk_1` FOREIGN KEY (`Alert_ID`) REFERENCES `alertsets` (`Alert_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `watches_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watches`
--

LOCK TABLES `watches` WRITE;
/*!40000 ALTER TABLE `watches` DISABLE KEYS */;
/*!40000 ALTER TABLE `watches` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-08 15:01:43
