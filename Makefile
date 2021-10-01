
.PHONY: help
help:   ## Show this help.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m[target]\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: setup
setup: ## setup gem something
	bundle config set path '.vendor/bundle'
	bundle install

.PHONY: host
host: ## host for all clients, not localhost-only
	bundle exec jekyll serve --livereload --host 0.0.0.0

.PHONY: host-localhost
host-localhost: ## host for localhost only
	bundle exec jekyll serve --livereload
