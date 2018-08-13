# Gremlin Add-on for BOSH

This beta BOSH release allows you to install Gremlin on your Cloud Foundry host virtual machines.

## NOTE: THIS IS A BETA - EXPECT CHANGES

Please contact support@gremlin.com with any questions or comments.

## Installation

Requirements:

- A running Cloud Foundry cluster
- BOSH to manage it

1. Download the latest `gremlin` release as a `.tgz` file here: https://github.com/gremlin/gremlin-boshrelease/releases
2. Upload it: `bosh upload-release gremlin_0.1.14.tgz`
3. Add a runtime config that uses gremlin (see examples if you need help): `bosh update-runtime-config gremlin-runtime-config.yml`
4. Re-deploy bosh: `bosh deploy your-deployment-manifest-here.yml`

## Dev setup

Install cf client:

`brew install cloudfoundry/tap/cf-cli`

Install cf dev plugin for cf CLI client:
NOTE: cf-dev currently only works on Mac.

`cf install-plugin -r CF-Community "cfdev"`

Start up a new cf dev cluster:

`cf dev start`

Export bosh environment variables:

```
eval "$(cf dev bosh env)"
export BOSH_ENVIRONMENT=cf
```

Confirm your BOSH connection to cf:

`bosh instances` should list all running BOSH VMs.

## Run me

- Upload this repo to bosh via `bosh upload-release`
- Update a bosh runtime config that references this repo (see `examples/runtime-config.example.yml` for a starting point, don't forget to update your own Gremlin team ID and team secret)
- Redeploy bosh to activate the runtime config that uses this latest gremlin addon

One-liner available at `make deploy_full`

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
