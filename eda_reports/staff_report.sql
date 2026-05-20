/*
==================================================================================================================================================================
Staff Report

Purpose:
    - Combines the data gathered during staff performance analysis.
    - Segments staff by score averages into 'Hidden Gem', 'Standard', or 'Underperformer'.

Threshold Logic:
    - The logic used to decide the outcomes of performance.
    - The logic can be changed to get a desired outcome. 
    - +2.0 for Potential: The dataset ceiling is roughly 3.66. This isolates the elite outliers (the 8s and 9s) from standard above-average staff.
    - -0.30 for Performance and Potential: The negative variances in this dataset are tightly clustered. This captures the absolute bottom floor of active staff.
    - 0.0 for Experience: This represents the exact department average. It is used to flag underperformers who have more tenure than the baseline.
=================================================================================================================================================================
*/
USE DataWarehouseBO
GO

WITH staff_performance_variance AS (
SELECT
    role_id,
    first_name,
    last_name,
    staff_role,
    department,
    performance_score,
    leadership_score,
    experience_score,
    potential_score,
    -- Instructions: calculates the variance from the department average.
    -- Outcome: if scores are negative, the staff member is under performing, score lower than average
    performance_score - AVG(performance_score * 1.0) OVER(PARTITION BY department) AS avg_performance_diff,
    leadership_score - AVG(leadership_score * 1.0) OVER(PARTITION BY department) AS avg_leadership_diff,
    experience_score - AVG(experience_score * 1.0) OVER(PARTITION BY department) AS avg_experience_diff,
    potential_score - AVG(potential_score * 1.0) OVER(PARTITION BY department) AS avg_potential_diff
FROM gold.dim_staff
)

SELECT
    role_id,
    first_name,
    last_name,
    staff_role,
    department,
    performance_score,
    leadership_score,
    experience_score,
    potential_score,
    CAST(avg_performance_diff AS FLOAT) AS avg_performance_diff,
    CAST(avg_leadership_diff AS FLOAT) AS avg_leadership_diff,
    CAST(ROUND(avg_experience_diff, 2) AS FLOAT) AS avg_experience_diff,
    CAST(ROUND(avg_potential_diff, 2) AS FLOAT) AS avg_potential_diff,
    CASE
        -- 1. Diamond in the Rough: Elite potential
        WHEN avg_potential_diff > 2.0 THEN 'Hidden Gem'
        -- 2. Fails in both performance AND potential, regardless of experience
        WHEN avg_performance_diff < -0.30 AND avg_potential_diff < -0.30 THEN 'Under Performer'
        -- 3. High Risk: Failing performance, but high experience (The "Was-Beens")
        WHEN avg_potential_diff < -0.30 AND avg_experience_diff > -0.30 THEN 'High Risk'
        ELSE 'Standard' 
    END AS staff_tiers
FROM staff_performance_variance
ORDER BY 
    CAST(REPLACE(role_id, 'stf_', '')AS INT) ASC -- converts the role_id int
