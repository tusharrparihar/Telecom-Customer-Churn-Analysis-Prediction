SELECT gender, count(gender) as Total_Count,
count(gender) * 100.0/(SELECT count(*) from customer_churn) as Percentage
from customer_churn
GROUP BY gender;

SELECT contract, count(contract) as Total_Count,
count(Contract) * 100.0 / (SELECT count(*) from customer_churn) as Percentage
from customer_churn
GROUP by contract;

SELECT customer_status, count(customer_status) as Total_Count,sum(total_revenue) as Total_Revenue,
sum(total_revenue) / (SELECT sum(total_revenue) from customer_churn) * 100 as Rev_Percentage
from customer_churn
GROUP by customer_status;

SELECT state, count(state) as Total_Count,
count(state) * 100.0 / (SELECT count(*) FROM customer_churn) as Percentage
from customer_churn
GROUP BY state
order by Percentage desc;

SELECT DISTINCT internet_type
from customer_churn;
