FROM certbot/dns-route53
MAINTAINER jaekwon park <jaekwon.park@code-post.com>

VOLUME /etc/letsencrypt/archive/

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache bash && \
    pip install --no-cache-dir awscli && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
