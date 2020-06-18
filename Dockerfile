ENV UNBOUND_P=r0
ENV LDNS=1.7.1-r1

FROM alpine:3.12

COPY root.hints unbound.conf /etc/unbound/

RUN apk update && \
        apk add --no-cache unbound ldns drill bind-tools && \
        unbound-anchor -v && \
        mv /usr/share/dnssec-root/trusted-key.key /etc/unbound/root.key && \
        chown -R unbound:unbound /etc/unbound

ENTRYPOINT ["unbound", "-c", "/etc/unbound/unbound.conf"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1", "||", "exit", "1" ]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
