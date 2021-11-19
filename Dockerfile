# For CentOS 7:
FROM centos:7.4.1708

# Install prerequisite packages:
RUN yum -y install wget ca-certificates epel-release

# Add NGINX Plus repo to Yum:
RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.4.repo

# Add NGINX App-protect repo to Yum:
RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/app-protect-7.repo

# Install NGINX App Protect:
#RUN --mount=type=secret,id=nginx-crt,dst=/etc/ssl/nginx/nginx-repo.crt,mode=0644 \
#    --mount=type=secret,id=nginx-key,dst=/etc/ssl/nginx/nginx-repo.key,mode=0644 \
RUN mkdir -p /etc/ssl/nginx/

COPY nginx-repo.crt nginx-repo.key /etc/ssl/nginx/
COPY default.conf /etc/nginx/conf.d/

#ADD nginx.conf /etc/nginx/

RUN  yum -y install app-protect \
    && yum clean all \
    && rm -rf /var/cache/yum

# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/cache/nginx/client_temp

# Copy configuration files:
#COPY nginx.conf custom_log_format.json /etc/nginx/
#RUN chmod 777 -R /usr/share/ts /var/log/app_protect /opt/app_protect /etc/app_protect /etc/nginx/nginx.conf /var/
#RUN chmod -R 777 /var/

RUN set -x \
	&& chmod go+w /var/cache/nginx \
	&& sed -i -e '/listen/!b' -e '/80;/!b' -e 's/80;/8080;/' /etc/nginx/conf.d/default.conf \
	&& sed -i -e '/user/!b' -e '/nginx/!b' -e '/nginx/d' /etc/nginx/nginx.conf \
	&& sed -i 's!/var/run/nginx.pid!/var/cache/nginx/nginx.pid!g' /etc/nginx/nginx.conf
	
COPY etc/nginx.conf /etc/nginx/
#COPY etc/example.com.conf /etc/nginx/conf.d/
COPY etc/status_api.conf /etc/nginx/conf.d/
COPY etc/waf /etc/nginx/waf

COPY entrypoint.sh /tmp

EXPOSE 8080 443 8443 9090

CMD ["sh", "/tmp/entrypoint.sh"]
