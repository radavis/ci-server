# CI Server

Inspired by instructions found, [here](https://developer.github.com/v3/guides/building-a-ci-server/)

## Features

* [x] ngrok or pagekite to expose app to the web.
* [x] Receive events from GitHub.
* [x] Persist events (mongo, firebase, redis, **sqlite**, whatever).
* [x] Persist repositories
* [-] Index page for events.
* [x] Index page for repositories.
* [-] Assign configuration and build instructions for a repository (POST).
* [ ] Filter unique, unprocessed events for a repo.
* [ ] Kickoff build process when push event occurs.
* [ ] Store build process state (started, running, stopped, complete, result).
* [ ] Post build result to Slack channel.
* [ ] Post build result to GitHub.

## Install ngrok

[Get Started](https://dashboard.ngrok.com/get-started)

```
$ brew cask install ngrok
$ ngrok authtoken YourAuthToken
$ ngrok http -host-header=localhost.dev 80
```

## Or Install pagekite

[Homepage](https://pagekite.net/)

```
$ curl -s https://pagekite.net/pk/ | sudo bash
$ pagekite.py 3000 username.pagekite.me
```

## Setup CI Server as a Service

[Source](https://blog.frd.mn/how-to-set-up-proper-startstop-services-ubuntu-debian-mac-windows/)

## SQLite Datatypes

* TEXT
* NUMERIC
* INTEGER (true/false, Time.now.to_i)
* REAL
* BLOB

## Flow

```
GitHub Event -> POST /events -> Insert into repositories, Insert into events
Scan for unprocessed events that have instructions.
Build the build in the build directory (Tmpdir.new).
  - clone it
  - configure it
  - build it
  - update build record with exit_code and build_output
POST results to GitHub.
POST results to Slack.
```

## Unprocessed Events

Which push events, that have repository configuration and build instructions,
have yet to be built?

```
select events.id, repositories.name, events.event_type, events.created_at from events
join
  repositories on events.repository_id = repositories.id
where
  repositories.build_instructions not null and
  events.event_type like 'push' and
  events.built = 0;
```
