FROM alpine:3.12 

COPY root.hints unbound.conf /tmp/

RUN apk update && \
	apk add --no-cache \
	unbound \
	ldns \
	drill \
	bind-tools && \
	unbound-anchor -a /tmp/root.key && \
	chown -f unbound:unbound /tmp/root.key

ENTRYPOINT ["cp", "-a", "-n", "/tmp/*", "/etc/unbound/", "&&", "unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1" ]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
