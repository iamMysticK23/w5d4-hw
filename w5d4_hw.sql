-- Question 1: 
-- This was done as an in class example
CREATE OR REPLACE PROCEDURE get_rekt(
	late_fee_amount DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
	ALTER TABLE payment
	ADD COLUMN late_fee NUMERIC(6,2),
	ADD COLUMN late_total NUMERIC(6,2);
	UPDATE payment
	SET late_fee = late_fee_amount
	WHERE rental_id IN (
		SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '7 Days');
		
	UPDATE payment	
	SET late_total = amount + late_fee_amount
	WHERE rental_id IN (
		SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '7 Days'
		
);
COMMIT;
END;
$$

-- Needed to use the commented out code to get this to work
-- ALTER TABLE payment
-- DROP COLUMN late_fee;

-- ALTER TABLE payment
-- DROP COLUMN late_total;


CALL get_rekt(5.00);


SELECT *
FROM payment
WHERE rental_id IN
(SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '7 Days');
		
		
--Question 2
-- Adding the platinum member column
ALTER TABLE customer
ADD COLUMN  platinum_member BOOLEAN;

SELECT *
FROM customer;

-- Creating procedure/function to update qualifying customers to platinum member
CREATE OR REPLACE FUNCTION is_platinum_member()
RETURNS VOID
AS $$
BEGIN
	UPDATE customer
	SET platinum_member = TRUE
	WHERE customer_id IN (
		SELECT payment.customer_id
		FROM(
			SELECT customer_id, SUM(amount) AS customer_spent
			FROM payment
			GROUP BY customer_id) AS payment
			WHERE payment.customer_spent > 200
);
	
	UPDATE customer
	SET platinum_member = FALSE
	WHERE customer_id NOT IN (
		SELECT payment.customer_id
		FROM(
			SELECT customer_id, SUM(amount) AS customer_spent
			FROM payment
			GROUP BY customer_id) AS payment
			WHERE payment.customer_spent > 200
);

END;
$$
LANGUAGE plpgsql

SELECT is_platinum_member();


-- Check tables with True and False values
-- To see platinum members

SELECT * 
FROM customer
WHERE platinum_member = TRUE;

SELECT * 
FROM customer
WHERE platinum_member = FALSE;





