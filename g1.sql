/*

Averages prompt correctness and reminders needed across prompt count for learners who
saw at least 12 prompts for Watercolor Game.

Note: Needs to be run separately for Cinder (prompt_id = 6118) and Leo (prompt_id = 6119) 

*/

SELECT prompt_count, AVG(CAST(correct AS INT)), AVG(CAST(reminders_needed AS INT)), COUNT(*) FROM
        (SELECT *,
        ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY created) AS prompt_count,
        CASE
                WHEN SUBSTRING(json, STRPOS(json, '\"1042\"') + 10, 4) = '2398' THEN '1'
                WHEN SUBSTRING(json, STRPOS(json, '\"1042\"') + 10, 4) = '2397' THEN '0'
        END AS correct,
        SUBSTRING(json, STRPOS(json, '\"1056\"') + 12, 1) AS reminders_needed
        FROM
                (SELECT learner_id, created, json,
                SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                FROM result) AS all_prompts
        WHERE learner_id IS NOT NULL AND prompt_id IN ('6119')) AS g1
        INNER JOIN
        (SELECT * FROM
        (SELECT learner_id, COUNT(*) AS num_prompts FROM
                (SELECT learner_id,
                ROW_NUMBER() OVER(PARTITION BY learner_id ORDER BY created) AS prompt_count
                FROM
                        (SELECT a.learner_id, a.created, a.json,
                        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
                        FROM result) AS all_prompts_2
                WHERE learner_id IS NOT NULL AND prompt_id IN ('6119')) AS g1_2
                GROUP BY learner_id) AS good_learners
        WHERE num_prompts >= 12) AS good_learners_2
        ON (g1.learner_id = good_learners_2.learner_id)
GROUP BY prompt_count;