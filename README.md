# CI Server

[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate)
[![Test Coverage](https://codeclimate.com/github/codeclimate/codeclimate/badges/coverage.svg)](https://codeclimate.com/github/codeclimate/codeclimate/coverage)

Inspired by instructions found, [here](https://developer.github.com/v3/guides/building-a-ci-server/)

## Features

* [x] ngrok or pagekite to expose app to the web.
* [x] Receive events from GitHub.
* [x] Persist events in sqlite.
* [x] Persist repositories.
* [x] Index page for events.
* [x] Index page for repositories.
* [x] Assign configuration and build instructions for a repository (POST).
* [x] Add clone URL for private repositories: `https://#{username}:#{token}@github.com/#{repo_name}.git`
* [ ] Interface for adding configuration and build instructions.
* [x] Filter unprocessed events for a repo.
* [ ] Kickoff build process when push event occurs.
* [x] Store build process state (started: true/false, exit_status: 0/non-zero).
* [ ] Create schedule for rake tasks: `rake ci:process_events`, `rake ci:build`
* [x] Post build result to Slack channel.
  - [ ] with branch name
  - [ ] with link to build status page
* [ ] Post build started to GitHub.
* [ ] Post build result to GitHub.
* [ ] "Restart Build" button.

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
$ ngrok http 3000
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
1. Start ngrok or pagekite
1. Create GitHub webhook with token and path to this application: `/events`
1. After test post from GitHub, check `/repositories`
1. Add build instructions and clone URL for repository. `rake db:query SQL=""`
1. Process events: `rake ci:process_events`
1. Build: `rake ci:build`

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

## General Flow

* GitHub Event -> POST /events -> Insert into repositories, Insert into events
* Scan for unprocessed events that have instructions. `rake ci:process_events`
* Build the build in the build directory. `rake ci:build`
  - clone it
  - configure it
  - build it
  - update build record with exit_code and build_report
* POST results to GitHub.
* POST results to Slack.

## Create a Service

[Source](https://blog.frd.mn/how-to-set-up-proper-startstop-services-ubuntu-debian-mac-windows/)
