drop table if exists repositories;
create table repositories (
  id integer primary key not null,
  name text not null,
  configuration_instructions text,
  build_instructions text,
  created_at integer not null,
  updated_at integer not null
);

create unique index index_name_on_repositories on repositories (name);

drop table if exists events;
create table events (
  id integer primary key not null,
  repository_id integer not null,
  event_type text not null,
  json_payload text not null,
  processed integer not null default 0,
  created_at integer not null,
  updated_at integer not null,
  foreign key (repository_id) references repositories (id)
);

drop table if exists builds;
create table builds (
  id integer primary key not null,
  repository_id integer not null,
  build_status text,
  build_output text,
  exit_status integer,
  created_at integer not null,
  updated_at integer not null,
  foreign key (repository_id) references repositories (id)
);
