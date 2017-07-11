# lita-slack-teamcity
A Lita plugin to trigger and list TeamCity build types.

### Notes and assumptions
- this repo has the Lita Development environment included for local deployment and debugging

### Setup these configs prior to starting bot
```
export TEAMCITY_SITE=<teamcity site url>
export TEAMCITY_USER=<teamcity user>
export TEAMCITY_PASS=<teamcity password>
```

### Start/Debug bot locally
1. ```$ vagrant up```
1. ```$ vagrant ssh```
1. ```$ lita-dev``` <--  wait for the lita dev environment to start up
1. ```bundle ; bundle exec lita```

# Commands for build bot
- ```@buildbot list``` - Lists all possible builds you can trigger.
- ```@buildbot list some_text*``` - Lists builds that match the case-sensitive wildcard by using `*`.
- ```@buildbot build id``` - Triggers a master build for build `id`.
- ```@buildbot build pr# for id``` - Triggers a PR build for passed in pr`#` and build `id`.
