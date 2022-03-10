USE toys_and_models;

SELECT * FROM orders;
SELECT * FROM products GROUP BY productLine LIMIT 3;
# The number of products sold by category
SELECT
    {fn MONTHNAME(o.orderDate)} as month,
	YEAR(o.orderDate) as year,
    productLine,
    SUM(ot.quantityOrdered),
	YEAR(orderDate) as year,
	LAG(ot.quantityOrdered) OVER (
		PARTITION BY MONTH(o.orderDate)
		ORDER BY YEAR(o.orderDate))
FROM products AS p
JOIN orderdetails AS ot ON ot.productCode = p.productCode
JOIN orders AS o ON ot.orderNumber = o.orderNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate), productLine
ORDER BY YEAR(o.orderDate), MONTH(o.orderDate), SUM(ot.quantityOrdered);

SELECT
    {fn MONTHNAME(orderDate)} as month,
	YEAR(orderDate) as year,
	LAG(salary) OVER (
		PARTITION BY employee_id
		ORDER BY fiscal_year) previous_salary
FROM
	orders;
#,
#LAG( SUM(ot.quantityOrdered) ) OVER ( ORDER BY YEAR(o.orderDate) ) AS Revenue_Previous_Year

SELECT productCode FROM products AS pd
LEFT JOIN orderdetails AS connect ON pd.productCode = connect.productCode;
# with comparison and rate of change compared to the same month of the previous year.



# Orders that have not yet been paid.
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


# turnover of the orders of the last two months by country
# Need to find orders > use orders table
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

#SELECT YEAR(shippedDate) FROM orders GROUP BY YEAR(shippedDate);

SELECT * FROM customers
LEFT JOIN employees ON employeeNumber = salesRepEmployeeNumber
GROUP BY salesRepEmployeeNumber;

/* HUMAN RESOURCES QUESTION */
SELECT MONTH(payments.paymentDate), customers.salesRepEmployeeNumber, firstName, lastName
FROM payments
LEFT JOIN customers
ON payments.customerNumber = customers.customerNumber
LEFT JOIN employees
ON employeeNumber = salesRepEmployeeNumber
GROUP BY employeeNumber, MONTH(paymentDate)
ORDER BY MONTH(paymentDate) DESC;
