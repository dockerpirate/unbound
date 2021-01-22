ARG ALPINE_M
ARG ALPINE_P

FROM alpine:$ALPINE_M.$ALPINE_P

ARG UNBOUND_M
ARG UNBOUND_P
ARG LDNS

COPY root.hints unbound.conf /etc/unbound/

RUN apk update && \
        apk add --no-cache unbound ldns drill bind-tools ca-certificates tzdata && \
        unbound-anchor -v && \
        mv /usr/share/dnssec-root/trusted-key.key /etc/unbound/root.key && \
        chown -R unbound:unbound /etc/unbound

ENTRYPOINT ["unbound", "-c", "/etc/unbound/unbound.conf"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD [ "drill", "-p", "53", "nlnetlabs.nl", "@127.0.0.1"]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
