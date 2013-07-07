/*

Calculates how much time an average learner spends in each game in A3 across their entire life.

*/


SELECT game_id, AVG(CAST(duration2 AS INT)) FROM
(SELECT learner_id, game_id, SUM(CAST(duration AS INT)) AS duration2 FROM
(SELECT * FROM
                        (SELECT learner_id, created, json,
                        SUBSTRING(json, STRPOS(json, '"type":') + CHAR_LENGTH('"type":'), 1) AS type,
                        SUBSTRING(json, STRPOS(json, '"gameId":') + CHAR_LENGTH('"gameId":'), 2) AS game_id,
                        CASE
                                WHEN CAST(SUBSTRING(json, STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":'))) AS INT) > 0
                                AND CAST(SUBSTRING(json, STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":'))) AS INT) <= 1000
                                        THEN SUBSTRING(json, STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":'), CHAR_LENGTH(json) - (STRPOS(json, '"duration":') + CHAR_LENGTH('"duration":')))
                                ELSE '0'
                        END AS duration
                        FROM result) AS all_prompts
                WHERE type = '1' AND game_id IN ('30', '31', '32', '33', '34')) AS prompts_w_duration
GROUP BY learner_id, game_id) AS sub_totals
GROUP BY game_id;