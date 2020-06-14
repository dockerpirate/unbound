FROM alpine:3.12 

RUN apk update && \
	apk add --no-cache \
	unbound \
	ldns \
	drill \
	bind-tools && \
	unbound-anchor -v	 

#COPY --from=build --chown=nobody:nogroup /var/run/unbound /var/run/unbound

COPY root.hints unbound.conf /etc/unbound/
RUN mv /usr/share/dnssec-root/trusted-key.key /etc/unbound/root.key && \
	chown -R unbound:unbound /etc/unbound

#USER unbound

ENTRYPOINT ["unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1" ]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
