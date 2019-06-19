#!/bin/bash

set -eo pipefail
set -x

brew install cloudfoundry/tap/cf-cli

cf install-plugin -r CF-Community cfdev

cf dev start
