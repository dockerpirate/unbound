FROM alpine:3.12 

COPY root.hints unbound.conf /var/tmp/unbound/

RUN apk update && \
	apk add --no-cache \
	unbound \
	ldns \
	drill \
	bind-tools && \
	unbound-anchor -a /var/tmp/unbound/root.key && \
	chown -R unbound:unbound /var/tmp/unbound/root.key

ENTRYPOINT ["cp", "-a", "-n", "/var/tmp/unbound/*", "/etc/unbound/", "&&", "unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1" ]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
