REPO_NAME := testing
SO_NAME := testing-wrapper.so
FAL_FILE := testing.fal
YML_FILE := falcon.yml
TARBALL := $(REPO_NAME).tar.gz

.PHONY: all test archive clean

all: test archive clean

test:
	cd tests; falcon-test ./run_tests.fal --log-level info

archive: $(YML_FILE) $(FAL_FILE) $(SO_NAME)
	tar -czvf $(TARBALL) $(YML_FILE) $(FAL_FILE) $(SO_NAME)

clean:
	rm -f $(TARBALL)
	rm -f $(SO_NAME)

