SELECT
    st.text AS [SQL],
    qp.query_plan AS [Execution Plan],
	cp.objtype AS [Object Type]
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.text LIKE '%xxxxxxxxxxxxx%';