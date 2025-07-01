DECLARE @Value DECIMAL(15, 5) = '74'; -- Can accept up to 5 decimal places
DECLARE @UnitFm CHAR(3) = 'TB'; -- Can convert down from 8KB unit up to 74 TB.
DECLARE @Return DECIMAL(15, 5);

SELECT @Return = -- Convert first to 8KB
	CASE UPPER(@UnitFm)
		WHEN '8KB' THEN @Value
		WHEN 'KB' THEN @Value / 8.00000
		WHEN 'MB' THEN (@Value / 8.00000) * 1024
		WHEN 'GB' THEN ((@Value / 8.00000) * 1024) * 1024
		WHEN 'TB' THEN (((@Value / 8.00000) * 1024) * 1024) * 1024
		ELSE NULL
	END

SELECT
	'Converting ' + CAST(@Value AS VARCHAR(20)) + SPACE(1) + @UnitFm AS [Convert],
    CAST(@Return AS DECIMAL(19, 2)) AS '8KB',
	CAST(@Return * 8.00 AS DECIMAL(19, 2)) AS 'KB',
	CAST(@Return / 128.00 AS DECIMAL(19, 2)) AS 'MB',
	CAST((@Return / 128.00) / 1024 AS DECIMAL(19, 2)) AS 'GB',
	CAST(((@Return / 128.00) / 1024) / 1024 AS DECIMAL(19, 2)) AS 'TB'

/*
8 bit		  = 1 byte
1024 byte	  = 1 kilobyte	  = KB
1024 kilobyte = 1 megabyte	  = MB
1024 megabyte = 1 gigabyte	  = GB
*/

/*
Q: Why 8KB/128 = 1mb?
A: When a page is an 8KB data, 1024KB = 1MB - so, if the value is 128, divide it by 8 to get 1(MB).
E: 256 (8kb) -> 256/128 = 2MB
*/

/*
no of pages	| multiply by 8 to get kb equivalent amount	| convert to mb
--------------------------------------------------------------------------
1	        | 8	                                        | 0.0078125
2	        | 16	                                    | 0.015625
3	        | 24	                                    | 0.0234375
4	        | 32	                                    | 0.03125
5	        | 40	                                    | 0.0390625
6	        | 48	                                    | 0.046875
7	        | 56	                                    | 0.0546875
8	        | 64	                                    | 0.0625
9	        | 72	                                    | 0.0703125
10	        | 80	                                    | 0.078125
20	        | 160	                                    | 0.15625
30	        | 240	                                    | 0.234375
40	        | 320	                                    | 0.3125
100	        | 800	                                    | 0.78125
110	        | 880	                                    | 0.859375
120	        | 960	                                    | 0.9375
121	        | 968	                                    | 0.9453125
121	        | 968	                                    | 0.9453125
125	        | 1000                                      | 0.9765625
128	        | 1024                                      | 1
*/