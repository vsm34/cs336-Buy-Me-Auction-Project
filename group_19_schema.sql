CREATE DATABASE  IF NOT EXISTS `buyme` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `buyme`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: buyme
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
  `AID` int NOT NULL AUTO_INCREMENT,
  `Password` varchar(50) NOT NULL,
  PRIMARY KEY (`AID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'adminpass');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alertsets`
--

DROP TABLE IF EXISTS `alertsets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alertsets` (
  `Alert_ID` int NOT NULL AUTO_INCREMENT,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `DateCreated` date NOT NULL DEFAULT (curdate()),
  `Username` varchar(50) NOT NULL,
  PRIMARY KEY (`Alert_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `alertsets_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4005 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertsets`
--

LOCK TABLES `alertsets` WRITE;
/*!40000 ALTER TABLE `alertsets` DISABLE KEYS */;
INSERT INTO `alertsets` VALUES (4001,1,'2025-11-23','buyer1'),(4002,1,'2025-11-23','buyer2'),(4003,0,'2025-11-23','buyer3'),(4004,1,'2025-12-06','rutgers');
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
  `Answer_Text` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`Q_ID`),
  KEY `CRID` (`CRID`),
  CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`Q_ID`) REFERENCES `questionasks` (`Q_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answers`
--

LOCK TABLES `answers` WRITE;
/*!40000 ALTER TABLE `answers` DISABLE KEYS */;
INSERT INTO `answers` VALUES (3001,100,'Yes, we ship with box and tags.'),(3002,101,'Returns are accepted within 30 days.'),(3003,101,'Shipping fees depend on seller and buyer locations.');
/*!40000 ALTER TABLE `answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction`
--

DROP TABLE IF EXISTS `auction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction` (
  `A_ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `Price` float NOT NULL,
  `CloseDate` date NOT NULL,
  `CloseTime` time NOT NULL,
  `Closed` tinyint(1) NOT NULL DEFAULT '0',
  `Subcategory` varchar(50) DEFAULT NULL,
  `SubAttribute` varchar(30) DEFAULT NULL,
  `reserve` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`A_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1206 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction`
--

LOCK TABLES `auction` WRITE;
/*!40000 ALTER TABLE `auction` DISABLE KEYS */;
INSERT INTO `auction` VALUES (1001,'Nike Dunk Low Panda',180,'2025-11-28','23:59:54',1,'streetwear','Size 10',0),(1002,'Air Jordan 1 Retro High',250,'2025-12-20','23:59:59',0,'basketball','Size 9',0),(1003,'Wilson Rush Pro 4.0',120,'2025-12-20','23:59:59',0,'tennis','Size 11',0),(1004,'FootJoy Pro SL Golf Shoes',160,'2025-12-20','23:59:59',0,'golf','Size 10W',0),(1101,'Yeezy Boost 350 V2 Zebra',220,'2025-12-20','23:59:59',0,'streetwear','Size 10',0),(1102,'Off-White x Nike Blazer',450,'2025-12-20','23:59:59',0,'streetwear','Size 9.5',0),(1103,'Nike Air Max 97 Silver Bullet',180,'2025-12-20','23:59:59',0,'streetwear','Size 11',0),(1104,'Kobe 6 Protro Grinch',390,'2025-12-20','23:59:59',0,'basketball','Size 11',0),(1105,'LeBron 20 Violet Frost',210,'2025-12-20','23:59:59',0,'basketball','Size 10',0),(1106,'KD 15 Brooklyn Courtside',150,'2025-12-02','00:11:21',1,'basketball','Size 12',0),(1107,'Asics Court FF 3 Novak',160,'2025-11-27','00:11:21',1,'tennis','Size 10',0),(1108,'Nike Vapor Pro 2',140,'2025-11-28','00:11:21',1,'tennis','Size 11',0),(1109,'Babolat Jet Mach 3',155,'2025-11-29','00:11:21',1,'tennis','Size 9',0),(1110,'Nike Air Zoom Infinity Tour',170,'2025-11-27','00:11:21',1,'golf','Size 10',0),(1111,'FootJoy Tour Alpha',190,'2025-11-28','00:11:21',1,'golf','Size 11',0),(1112,'Adidas ZG21 Motion Golf',150,'2025-11-30','00:11:21',1,'golf','Size 12',0),(1201,'Nike Air Force 1 Triple White',95,'2025-11-12','12:00:00',1,'streetwear','Size 10',0),(1202,'Jordan 4 Fire Red',220,'2025-11-04','13:00:00',1,'basketball','Size 11',0),(1203,'Asics Gel Resolution 8',130,'2025-11-09','11:00:00',1,'tennis','Size 10',0),(1204,'FootJoy HyperFlex Golf Shoe',150,'2025-10-30','10:30:00',1,'golf','Size 9',0),(1205,'Nike Airforce 1\'s',85,'2025-12-23','21:00:00',0,'streetwear','Size 10, White',100);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autobid`
--

LOCK TABLES `autobid` WRITE;
/*!40000 ALTER TABLE `autobid` DISABLE KEYS */;
INSERT INTO `autobid` VALUES (2002,5,210,190),(2005,2.5,150,135),(2102,5,260,240),(2104,10,520,470),(2105,10,520,480),(2106,10,550,500),(2110,5,450,410),(2111,5,450,430),(2113,5,260,230),(2115,3,180,165),(2116,4,190,170),(2118,2,170,155),(2120,3,190,170),(2121,4,200,175),(2123,4,210,190),(2125,5,230,210),(2127,3,180,165),(2128,3,185,170),(2130,5,300,270),(2202,5,130,110),(2204,10,260,245),(2206,5,150,140),(2208,5,180,162);
/*!40000 ALTER TABLE `autobid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bids` (
  `BID_ID` int NOT NULL AUTO_INCREMENT,
  `Price` float NOT NULL,
  `Time` time NOT NULL,
  PRIMARY KEY (`BID_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids`
--

LOCK TABLES `bids` WRITE;
/*!40000 ALTER TABLE `bids` DISABLE KEYS */;
INSERT INTO `bids` VALUES (2001,185,'00:00:00'),(2002,190,'00:00:00'),(2003,255,'00:00:00'),(2004,130,'00:00:00'),(2005,135,'00:00:00'),(2006,165,'00:00:00'),(2101,230,'00:00:00'),(2102,240,'00:00:00'),(2103,260,'00:00:00'),(2104,470,'00:00:00'),(2105,480,'00:00:00'),(2106,500,'00:00:00'),(2107,190,'00:00:00'),(2108,200,'00:00:00'),(2109,400,'00:00:00'),(2110,410,'00:00:00'),(2111,430,'00:00:00'),(2112,220,'00:00:00'),(2113,230,'00:00:00'),(2114,160,'00:00:00'),(2115,165,'00:00:00'),(2116,170,'00:00:00'),(2117,150,'00:00:00'),(2118,155,'00:00:00'),(2119,165,'00:00:00'),(2120,170,'00:00:00'),(2121,175,'00:00:00'),(2122,180,'00:00:00'),(2123,190,'00:00:00'),(2124,200,'00:00:00'),(2125,210,'00:00:00'),(2126,160,'00:00:00'),(2127,165,'00:00:00'),(2128,170,'00:00:00'),(2129,260,'00:00:00'),(2130,270,'00:00:00'),(2201,100,'00:00:00'),(2202,110,'00:00:00'),(2203,230,'00:00:00'),(2204,245,'00:00:00'),(2205,135,'00:00:00'),(2206,140,'00:00:00'),(2207,155,'00:00:00'),(2208,162,'00:00:00');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bids_on`
--

LOCK TABLES `bids_on` WRITE;
/*!40000 ALTER TABLE `bids_on` DISABLE KEYS */;
INSERT INTO `bids_on` VALUES (2001,1001),(2002,1001),(2003,1002),(2004,1003),(2005,1003),(2006,1004),(2101,1101),(2102,1101),(2103,1101),(2104,1102),(2105,1102),(2106,1102),(2130,1102),(2107,1103),(2108,1103),(2129,1103),(2109,1104),(2110,1104),(2111,1104),(2112,1105),(2113,1105),(2114,1107),(2115,1107),(2116,1107),(2117,1108),(2118,1108),(2119,1109),(2120,1109),(2121,1109),(2122,1110),(2123,1110),(2124,1111),(2125,1111),(2126,1112),(2127,1112),(2128,1112),(2201,1201),(2202,1201),(2203,1202),(2204,1202),(2205,1203),(2206,1203),(2207,1204),(2208,1204);
/*!40000 ALTER TABLE `bids_on` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_rep_create`
--

DROP TABLE IF EXISTS `customer_rep_create`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_rep_create` (
  `CRID` int NOT NULL AUTO_INCREMENT,
  `Password` varchar(50) NOT NULL,
  `AID` int NOT NULL,
  PRIMARY KEY (`CRID`),
  KEY `AID` (`AID`),
  CONSTRAINT `customer_rep_create_ibfk_1` FOREIGN KEY (`AID`) REFERENCES `admin` (`AID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_rep_create`
--

LOCK TABLES `customer_rep_create` WRITE;
/*!40000 ALTER TABLE `customer_rep_create` DISABLE KEYS */;
INSERT INTO `customer_rep_create` VALUES (100,'reppass1',1),(101,'reppass2',1);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deletes`
--

LOCK TABLES `deletes` WRITE;
/*!40000 ALTER TABLE `deletes` DISABLE KEYS */;
INSERT INTO `deletes` VALUES (101,1002);
/*!40000 ALTER TABLE `deletes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `end_user`
--

DROP TABLE IF EXISTS `end_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `end_user` (
  `Username` varchar(50) NOT NULL,
  `Password` varchar(25) NOT NULL,
  PRIMARY KEY (`Username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `end_user`
--

LOCK TABLES `end_user` WRITE;
/*!40000 ALTER TABLE `end_user` DISABLE KEYS */;
INSERT INTO `end_user` VALUES ('buyer1','pass_b1'),('buyer2','pass_b2'),('buyer3','pass_b3'),('rutgers','scarlet'),('seller1','pass_s1'),('seller2','pass_s2'),('user1','pass123');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generates_sales_report`
--

LOCK TABLES `generates_sales_report` WRITE;
/*!40000 ALTER TABLE `generates_sales_report` DISABLE KEYS */;
INSERT INTO `generates_sales_report` VALUES (1,5001),(1,5002),(1,5003),(1,5004),(1,5005);
/*!40000 ALTER TABLE `generates_sales_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manages`
--

DROP TABLE IF EXISTS `manages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manages` (
  `Username_DeleteAcc` varchar(50) NOT NULL,
  `Username_CreateAcc` varchar(50) NOT NULL,
  PRIMARY KEY (`Username_DeleteAcc`,`Username_CreateAcc`),
  KEY `Username_CreateAcc` (`Username_CreateAcc`),
  CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`Username_DeleteAcc`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `manages_ibfk_2` FOREIGN KEY (`Username_CreateAcc`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manages`
--

LOCK TABLES `manages` WRITE;
/*!40000 ALTER TABLE `manages` DISABLE KEYS */;
INSERT INTO `manages` VALUES ('seller1','buyer3');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manualbid`
--

LOCK TABLES `manualbid` WRITE;
/*!40000 ALTER TABLE `manualbid` DISABLE KEYS */;
INSERT INTO `manualbid` VALUES (2001),(2003),(2004),(2006),(2101),(2103),(2107),(2109),(2112),(2114),(2117),(2119),(2122),(2124),(2126),(2129),(2201),(2203),(2205),(2207);
/*!40000 ALTER TABLE `manualbid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places`
--

DROP TABLE IF EXISTS `places`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `places` (
  `Username` varchar(50) NOT NULL,
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`BID_ID`),
  KEY `BID_ID` (`BID_ID`),
  CONSTRAINT `places_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `places_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places`
--

LOCK TABLES `places` WRITE;
/*!40000 ALTER TABLE `places` DISABLE KEYS */;
INSERT INTO `places` VALUES ('buyer1',2001),('buyer2',2002),('buyer1',2003),('buyer2',2004),('buyer3',2005),('rutgers',2006),('buyer1',2101),('buyer2',2102),('buyer3',2103),('buyer1',2104),('buyer2',2105),('buyer3',2106),('buyer1',2107),('buyer2',2108),('buyer1',2109),('buyer2',2110),('buyer3',2111),('buyer2',2112),('buyer3',2113),('buyer1',2114),('buyer2',2115),('buyer3',2116),('buyer1',2117),('buyer2',2118),('buyer3',2119),('buyer1',2120),('buyer2',2121),('buyer1',2122),('buyer2',2123),('buyer3',2124),('buyer1',2125),('buyer2',2126),('buyer3',2127),('buyer1',2128),('buyer2',2129),('buyer3',2130),('buyer1',2201),('buyer2',2202),('buyer1',2203),('buyer3',2204),('buyer2',2205),('buyer3',2206),('buyer1',2207),('buyer2',2208);
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
  `Username` varchar(50) NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`A_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` VALUES ('2025-11-23','seller1',1001),('2025-11-23','seller1',1002),('2025-11-23','seller2',1003),('2025-11-23','seller2',1004),('2025-11-24','seller1',1101),('2025-11-24','seller1',1102),('2025-11-24','seller1',1103),('2025-11-24','seller2',1104),('2025-11-24','seller2',1105),('2025-11-24','seller2',1106),('2025-11-24','seller1',1107),('2025-11-24','seller2',1108),('2025-11-24','seller1',1109),('2025-11-24','seller2',1110),('2025-11-24','seller1',1111),('2025-11-24','seller2',1112),('2025-11-04','seller1',1201),('2025-10-30','seller1',1202),('2025-11-06','seller2',1203),('2025-10-25','seller2',1204),('2025-12-06','rutgers',1205);
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionasks`
--

DROP TABLE IF EXISTS `questionasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `questionasks` (
  `Q_ID` int NOT NULL AUTO_INCREMENT,
  `Q_Text` varchar(500) NOT NULL,
  `Username` varchar(50) NOT NULL,
  PRIMARY KEY (`Q_ID`),
  KEY `Username` (`Username`),
  CONSTRAINT `questionasks_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questionasks`
--

LOCK TABLES `questionasks` WRITE;
/*!40000 ALTER TABLE `questionasks` DISABLE KEYS */;
INSERT INTO `questionasks` VALUES (3001,'Do you ship with box and tags?','buyer1'),(3002,'Are returns accepted?','buyer2'),(3003,'How much does shipping cost?','rutgers');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `removes`
--

LOCK TABLES `removes` WRITE;
/*!40000 ALTER TABLE `removes` DISABLE KEYS */;
INSERT INTO `removes` VALUES (100,2004);
/*!40000 ALTER TABLE `removes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resets_pass`
--

DROP TABLE IF EXISTS `resets_pass`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resets_pass` (
  `Username` varchar(50) NOT NULL,
  `CRID` int NOT NULL,
  PRIMARY KEY (`Username`),
  KEY `CRID` (`CRID`),
  CONSTRAINT `resets_pass_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `resets_pass_ibfk_2` FOREIGN KEY (`CRID`) REFERENCES `customer_rep_create` (`CRID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resets_pass`
--

LOCK TABLES `resets_pass` WRITE;
/*!40000 ALTER TABLE `resets_pass` DISABLE KEYS */;
INSERT INTO `resets_pass` VALUES ('buyer3',101);
/*!40000 ALTER TABLE `resets_pass` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale`
--

DROP TABLE IF EXISTS `sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale` (
  `Sale_ID` int NOT NULL AUTO_INCREMENT,
  `A_ID` int NOT NULL,
  `Date` date NOT NULL,
  `Amount` float NOT NULL,
  PRIMARY KEY (`Sale_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5006 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale`
--

LOCK TABLES `sale` WRITE;
/*!40000 ALTER TABLE `sale` DISABLE KEYS */;
INSERT INTO `sale` VALUES (5001,1001,'2025-11-23',190),(5002,1201,'2025-11-13',110),(5003,1202,'2025-11-05',245),(5004,1203,'2025-11-10',140),(5005,1204,'2025-10-31',162);
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
  `Username` varchar(50) NOT NULL,
  `A_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`A_ID`),
  KEY `A_ID` (`A_ID`),
  CONSTRAINT `searches_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `searches_ibfk_2` FOREIGN KEY (`A_ID`) REFERENCES `auction` (`A_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `searches`
--

LOCK TABLES `searches` WRITE;
/*!40000 ALTER TABLE `searches` DISABLE KEYS */;
INSERT INTO `searches` VALUES (100,300,'buyer1',1001),(100,300,'buyer1',1002),(100,180,'buyer2',1003);
/*!40000 ALTER TABLE `searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `views_previous`
--

DROP TABLE IF EXISTS `views_previous`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `views_previous` (
  `Username` varchar(50) NOT NULL,
  `BID_ID` int NOT NULL,
  PRIMARY KEY (`Username`,`BID_ID`),
  KEY `BID_ID` (`BID_ID`),
  CONSTRAINT `views_previous_ibfk_1` FOREIGN KEY (`Username`) REFERENCES `end_user` (`Username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `views_previous_ibfk_2` FOREIGN KEY (`BID_ID`) REFERENCES `bids` (`BID_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `views_previous`
--

LOCK TABLES `views_previous` WRITE;
/*!40000 ALTER TABLE `views_previous` DISABLE KEYS */;
INSERT INTO `views_previous` VALUES ('buyer1',2001),('buyer2',2002),('rutgers',2002),('rutgers',2006),('rutgers',2103),('rutgers',2208);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watches`
--

LOCK TABLES `watches` WRITE;
/*!40000 ALTER TABLE `watches` DISABLE KEYS */;
INSERT INTO `watches` VALUES (4001,1001),(4001,1002),(4002,1003),(4004,1004),(4004,1101);
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

-- Dump completed on 2025-12-06  3:16:20
