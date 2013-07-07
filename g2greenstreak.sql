/*

Averages prompt correctness for red light prompts in Gyroracer across length trailing streak of
correct green prompts.

*/

SELECT green_streak, AVG(CAST(correct AS INT)), COUNT(*) FROM
(SELECT *, ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY created) AS prompt_count FROM
        (SELECT *,
        CASE
                WHEN SUBSTRING(json, STRPOS(json, '\"1058\"') + CHAR_LENGTH('\"1058\":['), 4) = '2394' THEN '1'
                ELSE '0'
        END AS correct,
        SUBSTRING(json, STRPOS(json, '\"1044\"') + CHAR_LENGTH('\"1044\":[\"'), 1) AS green_streak
        FROM
                (SELECT * FROM
                        (SELECT learner_id, created, json,
                        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                        FROM result) AS all_prompts
                WHERE prompt_id IN ('6121')) AS red_gyroracer) AS w_correct) AS w_prompt_count
GROUP BY green_streak;