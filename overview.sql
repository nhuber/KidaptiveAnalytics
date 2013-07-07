/*

Helpful generic script for grabbing all of the prompts of the same id for precursory inspection.

*/

SELECT COUNT(DISTINCT learner_id) FROM
        (SELECT learner_id, created, json,
        SUBSTRING(json, STRPOS(json, '"promptId":') + CHAR_LENGTH('"promptId":'), 4) AS prompt_id
        FROM result) AS all_prompts
WHERE prompt_id IN ('6118');