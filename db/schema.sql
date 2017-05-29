drop table if exists events;
create table events (
  id integer primary key not null,
  event_type text not null,
  body text not null,
  created_at integer not null
);
