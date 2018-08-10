VERSION=0.1.1
RELEASE_YML = $(shell ls -t dev_releases/bosh-gremlin/bosh*yml | head -1)
RELEASE_VERSION = $(shell echo $(RELEASE_YML) | ruby -e "puts gets.split('/').last.gsub(/.yml$$/, '').split('-').last")

ver:
	echo $(RELEASE_VERSION)

cut_release:
	bosh -n create-release --force

repush: deploy

bump_runtime_version:
	sed -i '' -E -e "s/version: 0+.+$$/version: $(RELEASE_VERSION)/" examples/runtime-config.yml

runtime: bump_runtime_version
	bosh -n update-runtime-config examples/runtime-config.yml

uninstall:
	bosh -n update-runtime-config examples/uninstall-runtime-config.yml
	bosh -n deploy examples/deployment_manifest.yml

deploy_full: release deploy

deploy: runtime
	# dump current deployment config to a temp file
	bosh manifest > tmp/deployment.yml
	# redeploy that same config file in order to activate the latest addon version
	bosh -n deploy ./tmp/deployment.yml

release: cut_release
	bosh -n upload-release $(RELEASE_YML)

logs:
	bosh ssh database "sudo tail -f /var/vcap/sys/log/gremlind/*log"

final_release:
	bosh create-release --final \
		--tarball=gremlin_$(VERSION).tgz \
		--force \
		--version=$(VERSION)
