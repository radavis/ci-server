drop table if exists events;
create table events (
  id integer primary key not null,
  event_type text not null,
  body text not null,
  processed integer not null default 0,
  created_at integer not null,
  updated_at integer not null
);
