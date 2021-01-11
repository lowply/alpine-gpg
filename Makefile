build:
	docker build . -t lowply/alpine-gpg

run:
	[ -d data ] || mkdir data
	docker run -it --rm -v $(CURDIR)/data:/root/data lowply/alpine-gpg
