-- Add Fine  column to inventory table
ALTER TABLE `inventory`
  ADD COLUMN `fine_box` int NOT NULL DEFAULT 0 AFTER `is_noc`;
