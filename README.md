# lita-slack-teamcity
A Lita plugin to trigger and list TeamCity build types.

### Make sure to setup these configs:
```
export TEAMCITY_SITE=<teamcity site url>
export TEAMCITY_USER=<teamcity user>
export TEAMCITY_PASS=<teamcity password>
```

### Notes and assumptions
- this repo has the Lita Development environment included for local deployment and debugging

### To start Lita bot locally
1. ```$ vagrant up```
1. ```$ vagrant ssh```
1. ```$ lita-dev``` <--  wait for the lita dev environment to start up
1. ```bundle ; bundle exec lita```
