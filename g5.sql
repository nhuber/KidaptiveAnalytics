/*

Averages prompt correctness and duration of prompts across number of prompts learners have seen in Housecatchers
for learners who have seen at least 12 prompts.

*/

SELECT prompt_count, AVG(CAST(correct AS INT)), AVG(CAST(duration AS INT)), COUNT(*) FROM

(SELECT *, ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY created) AS prompt_count FROM
        (SELECT *,
        CASE
                WHEN prompt_id = '6125' THEN CASE
                        WHEN SUBSTRING(json, STRPOS(json, '\"1054\"') + CHAR_LENGTH('\"1054\":['), 4) = '2384' AND SUBSTRING(json, STRPOS(json, '\"1055\"') + CHAR_LENGTH('\"1055\":['), 4) = '2389' THEN '1'
                        ELSE '0'
                        END
                WHEN prompt_id = '6126' THEN CASE
                        WHEN SUBSTRING(json, STRPOS(json, '\"1054\"') + CHAR_LENGTH('\"1054\":['), 4) = '2385' AND SUBSTRING(json, STRPOS(json, '\"1055\"') + CHAR_LENGTH('\"1055\":['), 4) = '2390' THEN '1'
                        ELSE '0'
                        END
                WHEN prompt_id = '6127' THEN CASE
                        WHEN SUBSTRING(json, STRPOS(json, '\"1054\"') + CHAR_LENGTH('\"1054\":['), 4) = '2386' AND SUBSTRING(json, STRPOS(json, '\"1055\"') + CHAR_LENGTH('\"1055\":['), 4) = '2387' THEN '1'
                        ELSE '0'
                        END
                WHEN prompt_id = '6128' THEN CASE
                        WHEN SUBSTRING(json, STRPOS(json, '\"1054\"') + CHAR_LENGTH('\"1054\":['), 4) = '2386' AND SUBSTRING(json, STRPOS(json, '\"1055\"') + CHAR_LENGTH('\"1055\":['), 4) = '2388' THEN '1'
                        ELSE '0'
                        END      
        END AS correct,
        CASE 
                WHEN CAST(SUBSTRING(json, STRPOS(json, '"duration"') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration"') + CHAR_LENGTH('"duration"') + 1)) AS INT) > 0 AND
                     CAST(SUBSTRING(json, STRPOS(json, '"duration"') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration"') + CHAR_LENGTH('"duration"') + 1)) AS INT) <= 60 THEN
                     SUBSTRING(json, STRPOS(json, '"duration"') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration"') + CHAR_LENGTH('"duration"') + 1))
                     ELSE '0' 
        END AS duration
        FROM
                (SELECT * FROM
                        (SELECT learner_id, created, json,
                        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                        FROM result) AS all_prompts
                WHERE prompt_id IN ('6125', '6126', '6127', '6128')) AS red_gyroracer) AS w_correct) AS w_prompt_count

INNER JOIN

                (SELECT learner_id FROM
                (SELECT learner_id, COUNT(*) AS num_prompts FROM
                (SELECT * FROM
                        (SELECT learner_id, created, json,
                        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                        FROM result) AS all_prompts2 
                WHERE prompt_id IN ('6125', '6126', '6127', '6128')) AS red_gyroracer2
                GROUP BY learner_id) AS good_learners
                WHERE num_prompts >= 12) AS good_learners2

ON (w_prompt_count.learner_id = good_learners2.learner_id)
                
GROUP BY prompt_count;
