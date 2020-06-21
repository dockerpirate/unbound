ARG ALPINE_M
ARG ALPINE_P=12
ARG UNBOUND_M=1.10.1
ARG UNBOUND_P=r0
ARG LDNS=1.7.1-r1

FROM alpine:$ALPINE_M.$ALPINE_P

ARG UNBOUND_M
ARG UNBOUND_P
ARG LDNS

COPY root.hints unbound.conf /etc/unbound/

RUN apk update && \
        apk add --no-cache unbound=$UNBOUND_M-$UNBOUND_P ldns=$LDNS drill bind-tools ca-certificates && \
        unbound-anchor -v && \
        mv /usr/share/dnssec-root/trusted-key.key /etc/unbound/root.key && \
        chown -R unbound:unbound /etc/unbound

ENTRYPOINT ["unbound", "-c", "/etc/unbound/unbound.conf"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1"]

RUN ["unbound", "-V"]
RUN ["drill", "-v"]
RUN ["dig", "-v"]
