VERSION=$(shell cat ./VERSION)
RELEASE_YML = $(shell ls -t dev_releases/gremlin/grem*yml | head -1)
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
	git add VERSION
	git commit -m "Bump version to $(VERSION)"
	bosh create-release --final \
		--tarball=gremlin_$(VERSION).tgz \
		--version=$(VERSION)
	git add releases/gremlin
	git commit -m "Release $(VERSION)"
	git tag -f -a $(VERSION) -m "Release $(VERSION)"
	git push
	git push --tags
