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
    SUM(ot.quantityOrdered)
FROM products AS p
JOIN orderdetails AS ot ON ot.productCode = p.productCode
JOIN orders AS o ON ot.orderNumber = o.orderNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate), productLine
ORDER BY YEAR(o.orderDate), MONTH(o.orderDate), SUM(ot.quantityOrdered);

/*
FINANCES QUESTION
The turnover of the orders of the last two months by country
*/
SELECT
	MONTH(shippedDate),
    customers.country,
    COUNT(orders.orderNumber),
    orderdetails.priceEach,
    COUNT(orders.orderNumber) * orderdetails.priceEach AS 'turnover'
FROM orders
# Find where the country > JOIN in customer table
LEFT JOIN customers /* name of the table to connect */
ON customers.customerNumber = orders.customerNumber /* compare values to select */
LEFT JOIN orderdetails /* name of the table to connect */
ON orderdetails.orderNumber = orders.orderNumber /* compare values to select */
# Find the dates > month > MONTH(shippedDate)
WHERE YEAR(shippedDate) = 2022
GROUP BY customers.country, MONTH(shippedDate)
# 2 last months
ORDER BY MONTH(shippedDate) DESC;

/*
FINANCES QUESTION
The turnover of the orders of the last two months by country.
Orders that have not yet been paid.
*/
SELECT
    o.customerNumber,
    o.orderNumber,
    # Check and compare the numbers between the orders and the payment
    count(DISTINCT o.orderNumber) as nb_orders,
    count(DISTINCT p.checkNumber) as nb_payments,
    count(DISTINCT o.orderNumber) - count(DISTINCT p.checkNumber) as diff
FROM orders as o
# Get the payments data throught customersNumber
LEFT JOIN payments as p ON p.customerNumber = o.customerNumber
# Select only orders were not canceled
WHERE NOT o.status = "Cancelled"
# Group BY customersNumber
GROUP BY customerNumber
# Select Customers with more orders then payments
HAVING diff > 0
ORDER BY diff DESC;

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
SELECT
	YEAR(payments.paymentDate) as year,
    MONTH(payments.paymentDate) as month,
    customers.salesRepEmployeeNumber as seller_id,
    firstName as seller_first_name,
    lastName as seller_last_name,
    SUM(payments.amount) as amount
FROM payments
LEFT JOIN customers
ON payments.customerNumber = customers.customerNumber
LEFT JOIN employees
ON employeeNumber = salesRepEmployeeNumber
GROUP BY employeeNumber, MONTH(paymentDate), YEAR(paymentDate)
ORDER BY year, month, amount DESC;
