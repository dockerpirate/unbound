FROM alpine:3.12 

COPY root.hints unbound.conf /tmp/unbound

RUN apk update && \
	apk add --no-cache \
	unbound \
	ldns \
	drill \
	bind-tools && \
	unbound-anchor -v && \
	mv /usr/share/dnssec-root/trusted-key.key /tmp/unbound/root.key && \
	chown -f unbound:unbound /tmp/unbound/root.key

ENTRYPOINT ["unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1" ]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
