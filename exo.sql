USE toys_and_models;
/*
SELECT * FROM orders;
SELECT * FROM products GROUP BY productLine LIMIT 3;
# The number of products sold by category
SELECT productLine, COUNT(productName) FROM products GROUP BY productLine;
#and by month,
SELECT productCode FROM products AS pd
LEFT JOIN orderdetails AS connect ON pd.productCode = connect.productCode;
# with comparison and rate of change compared to the same month of the previous year.
*/

# Orders that have not yet been paid.
# SELECT NOT cancel orders
SELECT customerNumber, COUNT(orderNumber)
FROM orders
WHERE NOT status = "Cancelled"
GROUP BY customerNumber
ORDER BY COUNT(orderNumber) DESC;
# select orders
SELECT customerNumber, COUNT(checkNumber)
FROM payments
GROUP BY customerNumber
ORDER BY COUNT(checkNumber) DESC;
# JOIN the 2 tables by customers table

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
