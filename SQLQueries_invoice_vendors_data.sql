

-- 8 Queries on Invoice and vendors data

---------------------------------------------------------------------------------------------------------------


-- Query 1

/* Fetch the following columns from the "invoices" table:
 - Invoice_Number        (The "invoice_number" column)
 - Invoice_Total         (The "invoice_total" column)
  - Payment_Credit_Total  ("payment_total" + "credit_total")
  - Balance_Due           ("invoice_total" - "payment_total" - "credit_total")

Only return invoices that have a balance due that is greater than $50.
Sort the result set by balance due in descending order and return only the rows with the 5 largest balance due.
*/

SELECT 
	invoice_Number AS Invoice_Number,
    invoice_Total AS Invoice_Total,
    (payment_total + credit_total) AS Payment_Credit_Total,
    (invoice_total - payment_total - credit_total) AS Balance_Due
FROM 
	invoices
WHERE 
	(invoice_total - payment_total - credit_total) > 50
ORDER BY
	Balance_Due DESC
LIMIT 5;


------------------------------------------------------------------------------------------

-- Query 2

/*
Identify all contact persons in the "vendors" table that satisfy the following criteria.
Return only the contact persons whose last name begins with the letter A, B, C or E.
*/


SELECT
	vendor_contact_last_name, vendor_contact_first_name
FROM
	vendors
WHERE
	vendor_contact_last_name LIKE 'a%' 
    OR vendor_contact_last_name LIKE 'b%' 
    OR vendor_contact_last_name LIKE 'c%' 
    OR vendor_contact_last_name LIKE 'e%'
ORDER BY
	vendor_contact_last_name ASC,
    vendor_contact_first_name ASC;

--------------------------------------------------------------------------------


-- Query 3


/*  Identify, for each vendor, the invoices with a non-zero balance due.

Return the following columns in the result set:

  - Vendor_Name     (The "vendor_name" column from the "vendors" table)
  - Invoice_Number  (The "invoice_number" column from the "invoices" table)
  - Invoice_Date    (The "invoice_date" column from the "invoices" table)
  - Balance_Due     ("invoice_total" - "payment_total" - "credit_total")
*/

-- I chose to join the tables invoices and vendors with INNER JOIN and selected the vendor_id as key
    
SELECT 
	vendor_name AS Vendor_Name,
    invoice_number AS Invoice_Number,
    invoice_date AS Invoice_Date,
    (invoice_total - payment_total - credit_total) AS Balance_Due
FROM
invoices 
	INNER JOIN 
vendors ON invoices.vendor_id = vendors.vendor_id
WHERE 
	(invoice_total - payment_total - credit_total) > 0
ORDER BY 
vendor_name ASC;
   

-------------------------------------------------------------------------------
    
-- Query 4

/*

Return one row for each vendor, which contains the following values:

  - Vendor_Name  (The "vendor_name" column from the "vendors" table)
  - The number of invoices (from the "invoices" table) for the vendor
  - The sum of "invoice_total" (from the "invoices" table) for the vendor
*/


SELECT 
	vendor_name, 
	COUNT(*) AS Number_of_invoices,
	SUM(invoice_total) AS Invoices_total
FROM 
	invoices 
		INNER JOIN 
	vendors ON invoices.vendor_id = vendors.vendor_id
GROUP BY
	vendor_name
ORDER BY
	Number_of_invoices DESC;

-----------------------------------------------------------------------------------------------


-- Query 5

/*
Return one row for each general ledger account, which contains the following values:

  - Account Number (The "account_number" column from the "general_ledger_accounts" table)
  - Account Description  (The "account_description" column from the "general_ledger_accounts" table)
  - The number of items in the "invoice_line_items" table that are related to the account
  - The sum of "line_item_amount" of the account

Return only those accounts, whose sum of line item amount is great than $5,000.
*/

SELECT
	G1.account_number AS account_number,
    account_description,
	COUNT(line_item_description) AS number_of_items, 
	SUM(line_item_amount) AS line_item_amount
FROM
	general_ledger_accounts AS G1
		INNER JOIN 
	invoice_line_items AS I2 ON G1.account_number = I2.account_number
GROUP BY
	G1.account_number
HAVING
	SUM(line_item_amount) > 5000.00
ORDER BY
	SUM(line_item_amount) DESC;

----------------------------------------------------------------------------------------------------


-- Query 6

/*
Identify all invoices, whose payment total is greater than the average payment total of all the invoices with a non-zero payment total.

Return the "invoice_number", "invoice_total", "payment_total" for each invoice satisfying the given criteria.
*/


SELECT
	invoice_number,
	invoice_total,
	payment_total
FROM
	invoices
WHERE  
	payment_total > (
		SELECT AVG(payment_total) 
		FROM invoices 
		WHERE payment_total > 0)
ORDER BY
	invoice_total DESC;

-------------------------------------------------------------------------------


-- Query 7

/*
Identify the accounts (from the "general_ledger_accounts" table), 
which do not match any invoice line items in the "invoice_line_items" table.

Return the following two columns in the result set:
	- "account_number" (from the "general_ledger_accounts" table)
	- "account_description" (from the "general_ledger_accounts" table)

Three different methods used
*/

-- Method 1

SELECT 
	account_number, 
	account_description
FROM 
	general_ledger_accounts
WHERE 
	NOT EXISTS(
    SELECT account_number 
    FROM invoice_line_items 
    WHERE invoice_line_items.account_number = general_ledger_accounts.account_number)

ORDER BY 
	account_number ASC;


-- Method 2

SELECT
	G1.account_number,
	account_description
FROM 
	general_ledger_accounts AS G1
LEFT JOIN 
	invoice_line_items AS I2 ON I2.account_number = G1.account_number
WHERE 
	I2.account_number IS NULL
ORDER BY
	G1.account_number ASC;
    
    
-- Method 3

SELECT 
	account_number, 
    account_description
FROM 
	general_ledger_accounts
WHERE 
	account_number NOT IN (
		SELECT account_number 
		FROM invoice_line_items)
ORDER BY 
	account_number ASC;


------------------------------------------------------------------------------------------


-- Query 8
/*
Return one row per vendor, which includes the information on the vendor's oldest invoice (the one with the earliest date).

Each row returned should include the following values:

  - "vendor_name"
  - "invoice_number"
  - "invoice_date"
  - "invoice_total"
*/


SELECT 
	vendor_name, 
    invoice_number, 
    invoice_date, 
    invoice_total
FROM
	vendors
		INNER JOIN
	invoices ON vendors.vendor_id = invoices.vendor_id
WHERE
	invoice_date = (
		SELECT DISTINCT MIN(invoice_date) 
		FROM invoices AS invoices_2
		WHERE invoices.vendor_id = invoices_2.vendor_id)

ORDER BY
	vendor_name ASC;
    