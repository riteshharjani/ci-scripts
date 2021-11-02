help:
	@echo "Golang build test"
	@echo "Available targets:"
	@echo "  download 	# download required sources"
	@echo "  test 		# run the test"

version = 1.16.6
tarball = go${version}.tar.gz

download: ${tarball}

${tarball}:
	wget -O $@.tmp https://github.com/golang/go/archive/refs/tags/${tarball}
	mv $@.tmp $@

test: download
	@./test.sh

clean:
	rm -rf go-go${version}

distclean: clean
	rm -f ${tarball}

.PHONY: download test clean distclean help
