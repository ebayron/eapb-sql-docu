UPDATE a
SET a.col2 = b.col2
FROM <table1> a
<JOIN type> (
	<SELECT statement>
) b ON a.col1 = b.col1