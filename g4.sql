/*

Averages prompt correctness, number of fireflies needed to be found and number of distractor flies
across number of prompts learners have seen in Fireflies Game for learners who have seen at least 5 prompts.

Note: Needs to be run separately for num_flies = {1, 2, 3} (prompt_id = 6129 are for single fly events,
prompt_id = 6130 are for multiple fly events)

*/

SELECT prompt_count, AVG(CAST(correct AS INT)), AVG(CAST(num_flies AS INT)), AVG(CAST(num_d_flies AS INT)), COUNT(*) FROM

(SELECT *, ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY created) AS prompt_count FROM
        (SELECT *,
        CASE
                WHEN SUBSTRING(json, STRPOS(json, '\"1060\"') + CHAR_LENGTH('\"1060\":['), 4) = '2400' THEN '1'
                ELSE '0'
        END AS correct,
        SUBSTRING(json, STRPOS(json, '\"1045\"') + CHAR_LENGTH('\"1045\":[\"'), 1) AS num_flies,
        SUBSTRING(json, STRPOS(json, '\"1046\"') + CHAR_LENGTH('\"1046\":[\"'), 1) AS num_d_flies,
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
                WHERE prompt_id IN ('6129')) AS red_gyroracer) AS w_correct 
                WHERE num_flies = '1')
                AS w_prompt_count

INNER JOIN

                (SELECT learner_id FROM
                (SELECT learner_id, COUNT(*) AS num_prompts FROM
                (SELECT *, 
                SUBSTRING(json, STRPOS(json, '\"1045\"') + CHAR_LENGTH('\"1045\":[\"'), 1) AS num_flies,
                SUBSTRING(json, STRPOS(json, '\"1046\"') + CHAR_LENGTH('\"1046\":[\"'), 1) AS num_d_flies FROM
                        (SELECT learner_id, created, json,
                        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                        FROM result) AS all_prompts2 
                WHERE prompt_id IN ('6129')) AS red_gyroracer2
                WHERE num_flies = '1'
                GROUP BY learner_id) AS good_learners
                WHERE num_prompts >= 5) AS good_learners2

ON (w_prompt_count.learner_id = good_learners2.learner_id)
                
GROUP BY prompt_count;
