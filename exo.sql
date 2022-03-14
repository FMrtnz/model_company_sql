USE toys_and_models;

/*
SALES QUESTION
The number of products sold by category and by month,
with comparison and rate of change compared to the same month of the previous year.
*/

SELECT
    {fn MONTHNAME(o.orderDate)} as month,
	YEAR(o.orderDate) as year,
    productLine,
    #COUNT(ot.productCode) AS nb_products_sell,
    SUM(ot.quantityOrdered) as rate
FROM products AS p
JOIN orderdetails AS ot ON ot.productCode = p.productCode
JOIN orders AS o ON ot.orderNumber = o.orderNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY productLine, MONTH(o.orderDate), YEAR(o.orderDate);

/*
FINANCES QUESTION
The turnover of the orders of the last two months by country
*/

SELECT
    c.country,
    SUM(od.quantityOrdered * od.priceEach) as turnover
FROM orders AS o
# Find where the country > JOIN in customer table
LEFT JOIN customers as c /* name of the table to connect */
ON c.customerNumber = o.customerNumber /* compare values to select */
LEFT JOIN orderdetails as od /* name of the table to connect */
ON od.orderNumber = o.orderNumber /* compare values to select */
# Find the dates > month > MONTH(shippedDate)
WHERE MONTH(o.shippedDate) >= MONTH(NOW() - INTERVAL 2 MONTH) AND YEAR(o.shippedDate) = YEAR(NOW())
GROUP BY c.country;

/*
FINANCES QUESTION
Orders that have not yet been paid.
*/

WITH sub_order AS (
SELECT
	o.customerNumber,
	o.orderNumber,
	SUM(DISTINCT od.quantityOrdered * od.priceEach) as amount_order
FROM orders AS o
LEFT JOIN orderdetails as od ON od.orderNumber = o.orderNumber
GROUP BY o.orderNumber
)
SELECT * FROM orders
# Reject orders that have a same customer number and same total than amout of payment
WHERE NOT orderNumber IN (
SELECT o.orderNumber FROM sub_order as o
JOIN payments as p ON p.customerNumber = o.customerNumber
WHERE p.amount = o.amount_order)
AND NOT status = "cancelled";


/*
LOGISTIC QUESTION
The stock of the 5 most ordered products
*/

SELECT o.productCode, SUM(o.quantityOrdered) as qty_ordered, p.quantityInStock as available_qty FROM orderdetails as o
JOIN products as p ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY SUM(o.quantityOrdered) DESC
LIMIT 5;

/*
HUMAN RESOURCES QUESTION
Each month, the 2 sellers with the highest turnover.
*/
# Create a first select to get performence of all sellers by year and then by month
WITH t1 AS (SELECT
	# Identify the year then the month for each seller performence
	YEAR(payments.paymentDate) as year,
    MONTH(payments.paymentDate) as month,
    # Get the seller from the payment through the customer
    customers.salesRepEmployeeNumber as seller_id,
    firstName as seller_first_name,
    lastName as seller_last_name,
    # Get the amount earns by seller
    SUM(payments.amount) as amount,
    # Set a position to be able to select the best seller
    ROW_NUMBER() OVER(PARTITION BY year, month ORDER BY amount DESC) AS position
FROM payments
# Get the seller from the payment through the customer
LEFT JOIN customers
ON payments.customerNumber = customers.customerNumber
LEFT JOIN employees
ON employeeNumber = salesRepEmployeeNumber
GROUP BY employeeNumber, MONTH(paymentDate), YEAR(paymentDate)
ORDER BY year, month, amount DESC)
# Doing a second select to choose the 2 first sellers by year then month
SELECT * FROM t1
WHERE position < 3
ORDER BY year, month, position;
