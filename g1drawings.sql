/*

Selects watercolors created by learners in Watercolor Game.

*/

SELECT * FROM event 
INNER JOIN
learner_content
ON (event.id = learner_content.event_id)
WHERE game_id = 30
ORDER BY learner_id, created;