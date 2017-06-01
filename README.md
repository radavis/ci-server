# CI Server

Inspired by instructions found, [here](https://developer.github.com/v3/guides/building-a-ci-server/)

## Features

* [x] ngrok or pagekite to expose app to the web.
* [x] Receive events from GitHub.
* [x] Persist events (mongo, firebase, redis, **sqlite**, whatever).
* [x] Persist repositories.
* [x] Index page for events.
* [x] Index page for repositories.
* [x] Assign configuration and build instructions for a repository (POST).
* [x] Filter unprocessed events for a repo.
* [ ] Kickoff build process when push event occurs.
* [x] Store build process state (started: true/false, exit_status: 0/non-zero).
* [ ] Post build result to Slack channel.
* [ ] Post build result to GitHub.

## Technology

* Ruby
* Sinatra
* SQLite3
* RSpec

## Setup

### Install ngrok

[Get Started](https://dashboard.ngrok.com/get-started)

```
$ brew cask install ngrok
$ ngrok authtoken YourAuthToken
$ ngrok http -host-header=localhost.dev 80
```

### Or Install pagekite

[Homepage](https://pagekite.net/)

```
$ curl -s https://pagekite.net/pk/ | sudo bash
$ pagekite.py 3000 username.pagekite.me
```

### Steps

1. `git clone github.com/radavis/ci-server`
1. `cd ci-server && bundle && rake db:schema_load && rake`
1. Generate a token: `rake ci:generate_token`
1. Start ngrok or pagekite, if necessary
1. Create GitHub webhook with token and path to this running application: `/events`
1. After test post, check `/repositories`
1. Add build instructions for repository.
1. Process events: `rake ci:process_events`
1. Build: `rake ci:build`.

```
Update builds.id: 6 set to started for radavis/local-events.
builds.id: 6 for radavis/local-events started.
  executing: git init
  executing: git remote add origin https://github.com/radavis/local-events.git
  executing: git pull origin master
  executing: git checkout e180892abd9697cfe0e99e3dba2e53ad3787ad68
  executing: gem install bundler
  executing: rspec spec
builds.id: 6 for radavis/local-events exited with 1 exit status.
```

Check the build report: `rake db:query SQL='select build_report from builds where id = 6'`

## Setup CI Server as a Service

[Source](https://blog.frd.mn/how-to-set-up-proper-startstop-services-ubuntu-debian-mac-windows/)

## Genral Flow

* GitHub Event -> POST /events -> Insert into repositories, Insert into events
* Scan for unprocessed events that have instructions.  `rake ci:process_events`
* Build the build in the build directory (Tmpdir.new).  `rake ci:build`
  - clone it
  - configure it
  - build it
  - update build record with exit_code and build_output
* POST results to GitHub.
* POST results to Slack.
