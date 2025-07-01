USE [distribution]

SELECT DISTINCT
	p.publication,
	CASE p.publication_type
		WHEN 0 THEN 'Transactional'
		WHEN 1 THEN 'Snapshot'
		WHEN 2 THEN 'Merge'
	END AS publication_type,
	s.subscriber_id,
	s.update_mode,
	CASE s.subscription_type
		WHEN 0 THEN 'Push'
		WHEN 1 THEN 'Pull'
		WHEN 2 THEN 'Anonymous'
	END AS subscription_type,
	CASE s.sync_type
		WHEN 1 THEN 'Automatic'
		WHEN 2 THEN 'No Synchronization'
	END AS sync_type,
	CASE s.[status]
		WHEN 0 THEN 'Inactive'
		WHEN 1 THEN 'Active'
	END AS [status]
FROM mspublications p
INNER JOIN mssubscriptions s ON p.publication_id = s.publication_id