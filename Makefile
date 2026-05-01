.PHONY: test archive release clean help

VERSION := 1.0.0 
REPO_NAME := testing
SO_NAME := testing-wrapper.so
FAL_FILE := testing.fal
YML_FILE := falcon.yml
TARBALL := $(REPO_NAME).tar.gz

help: ## Show available targets
	@echo "Falcon Testing Package"
	@echo "======================"
	@echo "Version: $(VERSION)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

test: ## Run tests
	cd tests && falcon-test ./run_tests.fal --log-level info

update-license: $(YML_FILE) ## Update falcon.yml license to MPL-2.0
	@if command -v yq &> /dev/null; then \
		yq eval '.license = "MPL-2.0"' -i $(YML_FILE); \
	else \
		sed -i '/^license:/s/.*/license: MPL-2.0/' $(YML_FILE) || \
		sed -i '' '/^license:/s/.*/license: MPL-2.0/' $(YML_FILE); \
	fi
	@echo "✓ Updated license to MPL-2.0 in $(YML_FILE)"

archive: update-license $(SO_NAME) ## Create release tarball
	tar -czvf $(TARBALL) $(YML_FILE) $(FAL_FILE) $(SO_NAME)

check-clean: ## Verify working tree is clean
	@git diff-index --quiet HEAD -- || \
		(echo "❌ Working tree is dirty. Commit changes first!" && exit 1)

release: check-clean archive ## Tag, commit, and create GitHub release
	@echo "🚀 Creating release v$(VERSION)"
	@git tag -a v$(VERSION) -m "Release v$(VERSION)" 2>/dev/null || echo "ℹ️  Tag v$(VERSION) already exists"
	@git push origin main
	@git push origin v$(VERSION) 2>/dev/null || true
	@if command -v gh &> /dev/null; then \
		if gh release view v$(VERSION) >/dev/null 2>&1; then \
			echo "Release v$(VERSION) exists, deleting and recreating..."; \
			gh release delete v$(VERSION) --yes; \
		fi; \
		gh release create v$(VERSION) $(TARBALL) \
			--title "Release v$(VERSION)" \
			--generate-notes; \
	else \
		echo "⚠️  GitHub CLI not installed. Skipping GitHub release."; \
	fi
	@echo "✅ Release v$(VERSION) complete!"

clean: ## Remove build artifacts
	rm -f $(TARBALL) $(SO_NAME) $(YML_FILE) 
	rm -rf .falcon
	@echo "✓ Clean complete"
