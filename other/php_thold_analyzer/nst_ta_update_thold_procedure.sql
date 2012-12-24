DROP PROCEDURE IF EXISTS `nst_ta_update_thold`;
DELIMITER //
CREATE PROCEDURE `nst_ta_update_thold`(IN accnum int, IN ver int)
BEGIN
	SET @fpi_table = CONCAT('nst_ta_fpi_',accnum);
	SET @tho_table = CONCAT('nst_ta_thold_',accnum);

	/*-- get max ring index*/
	SET @sql = concat('SELECT MAX(`ringidx`) INTO @maxringidx FROM `',@fpi_table,'` LIMIT 200');
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;
	DEALLOCATE PREPARE stmt1;
	SET @i = 0;

	/*-- get max ring index*/
	IF ver=4 THEN
		SET @i = @i + 1;
		SET @maxringidx = @maxringidx + 1;
	END IF;
	
	/* */
	WHILE @i < @maxringidx DO
		/* insert ringidx if have not*/
		SET @sql = concat('INSERT IGNORE INTO ',@tho_table,' (`ringidx`) VALUES (@i)');
		PREPARE stmt1 FROM @sql;
		EXECUTE stmt1;
		DEALLOCATE PREPARE stmt1;
		/* get avg fpi*/
		SET @sql = concat('SELECT (SUM(lfpi) - MAX(lfpi) - MIN(lfpi))/(COUNT(*)-2) as _lavg,(SUM(sfpi) - MAX(sfpi) - MIN(sfpi))/(COUNT(*)-2) as _savg INTO @lavg, @savg
											FROM ',@fpi_table,' WHERE ringidx=@i AND sfpi>0 AND lfpi>0');
		PREPARE stmt1 FROM @sql;
		EXECUTE stmt1;
		DEALLOCATE PREPARE stmt1;
		/* calculate thold value */
		SET @lthold = @lavg - 0.0005;
		SET @sthold = @savg + 0.0005;
		/* update new thold to db */
		SET @sql = concat('UPDATE ',@tho_table,' SET lthold=@lthold,sthold=@sthold WHERE ringidx=@i');
		PREPARE stmt1 FROM @sql;
		EXECUTE stmt1;
		DEALLOCATE PREPARE stmt1;
		
		SET @i = @i + 1;
	END WHILE;

END
//
DELIMITER ;

/*


DROP EVENT IF EXISTS new_thold_7070;
CREATE EVENT IF NOT EXISTS new_thold_7070 
ON SCHEDULE EVERY HOUR
DO CALL nst_ta_update_thold(7070, 4);*/