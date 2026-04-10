.PHONY: help test content preflight data qa

help: ## Show this help message
	@echo "Grafana Assistant Workshop — Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

test: content preflight data ## Run all automated tests (content + stack + data)

content: ## Validate lab markdown structure and links
	@bats tests/workshop-content.bats

preflight: ## Check Grafana stack health, auth, and features
	@bats tests/workshop-preflight.bats

data: ## Verify lab query data exists in the environment
	@bats tests/workshop-data.bats

qa: ## Full AI-powered QA via Claude Code + Chrome (run day before workshop)
	@bash scripts/workshop-qa.sh
