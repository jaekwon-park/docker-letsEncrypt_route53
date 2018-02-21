FROM ubuntu:16.04
MAINTAINER jaekwon park <jaekwon.park@code-post.com>

VOLUME /etc/letsencrypt/archive/

# Configure apt
RUN apt-get update && \
	  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common python-pip && \
    add-apt-repository -y  ppa:certbot/certbot && \
    apt-get update && \
	  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends certbot && \
    pip install --upgrade pip && pip install --upgrade setuptools && pip install certbot-route53 awscli && \
    apt-get purge python-pip software-properties-common -y  && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
