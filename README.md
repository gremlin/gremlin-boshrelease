# Gremlin Add-on for BOSH

This beta BOSH release allows you to install Gremlin on your Cloud Foundry host virtual machines.

## NOTE: THIS IS A BETA - EXPECT CHANGES

Please contact support@gremlin.com with any questions or comments.

## Dev setup

- install cf client
- install cf dev plugin for cf CLI client
- start up a new cf dev cluster

## Run me

- upload this repo to bosh via `bosh upload-release`
- update a bosh runtime config that references this repo
- redeploy bosh to activate the runtime config that uses this latest gremlin addon

## Monitoring and health checks

Log in to a bosh instance to look for gremlin:

```
bosh ssh database
sudo su

# check out installation logs
cd /var/vcap/sys/log/gremlind
tail *log

# check out installation process artifacts
cd /var/vcap/sys/jobs/gremlind
ls

# load gremlin env vars for proper API connection
. /etc/default/gremlind

# check the gremlin logs
tail /var/log/gremlin/daemon.log /var/log/gremlind-std*log

monit status # see if gremlind is up

# run basic localhost checks
gremlin syscheck
```

## Quick overview on what B