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
	SET @maxringidx = @maxringidx + 1;

	/*-- get max ring index*/
	IF ver=4 THEN
		SET @i = @i + 1;
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
		SET @lthold = @lavg - 0.0006;
		SET @sthold = @savg + 0.0006;
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

/* call all procdeure */
DROP PROCEDURE IF EXISTS `call_all_update_thold`;
DELIMITER //
CREATE PROCEDURE `call_all_update_thold`()
BEGIN
	CALL nst_ta_update_thold(833,4);
	CALL nst_ta_update_thold(7070,4);
	CALL nst_ta_update_thold(11072059,4);
	CALL nst_ta_update_thold(20039706,5);
END
//
DELIMITER ;



/* call event */
DROP EVENT IF EXISTS nst_call_all;
CREATE EVENT nst_call_all
    ON SCHEDULE EVERY HOUR
    DO
      CALL call_all_update_thold();