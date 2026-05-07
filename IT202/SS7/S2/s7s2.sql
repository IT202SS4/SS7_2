CREATE DATABASE IF NOT EXISTS TrainingDB;
USE TrainingDB;

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL
);

INSERT INTO Payments (student_id, amount, payment_date) VALUES
(1, 3000000, '2024-01-10'),
(1, 4500000, '2024-02-15'),
(1, 5000000, '2024-03-20'),
(2, 2000000, '2024-01-05'),
(2, 3000000, '2024-02-10'),
(3, 8000000, '2024-01-08'),
(3, 6000000, '2024-02-12'),
(4, 1500000, '2024-01-15'),
(5, 12000000, '2024-03-01');

SELECT SUM(total_spent)
FROM (
    SELECT student_id, SUM(amount) AS total_spent
    FROM Payments
    GROUP BY student_id
    HAVING SUM(amount) > 10000000
) AS vip_students;