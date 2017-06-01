-- unprocessed events
select events.id, repositories.name, events.event_type, events.created_at from events
join
  repositories on events.repository_id = repositories.id
where
  repositories.build_instructions not null and
  events.built = 0 and
  events.event_type like 'push';

select repositories.id, repositories.name, events.processed, builds.started, builds.exit_status
from repositories
join events on repositories.id = events.repository_id
join builds on repositories.id = builds.repository_id;

select repositories.id, repositories.name
from repositories;

select repositories.id, repositories.name, events.processed
from repositories
join events on repositories.id = events.repository_id;

select * from events
join repositories on events.repository_id = repositories.id
where repositories.build_instructions not null and
  events.event_type like 'push' and
  events.processed = 0;

select * from events where events.event_type like 'push'

select repository_id, events.id, processed, event_type from events
join repositories on events.repository_id = repositories.id
where repositories.build_instructions not null and
events.processed = 0 and
events.event_type like 'push';
