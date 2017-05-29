# CI Server

Inspired by instructions found, [here](https://developer.github.com/v3/guides/building-a-ci-server/)

## Features

* [ ] ngrok or pagekite to expose app to the web.
* [x] Receive events from GitHub.
* [x] Persist events (mongo, firebase, redis, **sqlite**, whatever).
* [ ] Kickoff build process when push event occurs.
* [ ] Store build process state (started, running, stopped, complete, result).
* [ ] Post build process result to Slack channel.

## Install ngrok

[Get Started](https://dashboard.ngrok.com/get-started)

```
$ brew cask install ngrok
$ ngrok authtoken YourAuthToken
$ ngrok http -host-header=localhost.dev 80
```

## Setup CI Server as a Service

[Source](https://blog.frd.mn/how-to-set-up-proper-startstop-services-ubuntu-debian-mac-windows/)
