-- Run this on your bike inventory database before using Sold Return

CREATE TABLE IF NOT EXISTS `inventory_sold_return` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bike_id` int NOT NULL,
  `old_sale_amount` double(10,3) DEFAULT NULL,
  `old_sold_date` date DEFAULT NULL,
  `old_sale_remark` text,
  `return_reason` text NOT NULL,
  `return_date_time` datetime NOT NULL,
  `uid` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bike_idx` (`bike_id`),
  KEY `return_date_idx` (`return_date_time`),
  KEY `uid_idx` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
