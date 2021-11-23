# For CentOS 7:
FROM centos:7.4.1708

RUN mkdir -p /etc/ssl/nginx
RUN mkdir -p /etc/nginx
COPY nginx-repo.crt /etc/ssl/nginx/
COPY nginx-repo.key /etc/ssl/nginx/

# Install prerequisite packages:
RUN yum -y install wget ca-certificates epel-release

# Add NGINX Plus repo to Yum:
RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.4.repo

# Add NGINX App-protect repo to Yum:
RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/app-protect-7.repo

# Install NGINX App Protect WAF:
RUN yum -y install app-protect app-protect-attack-signatures \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -f /etc/ssl/nginx/nginx-repo.*

# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log 
    #&& mkdir -p /var/cache/nginx/client_temp

# Copy configuration files:
#COPY nginx.conf custom_log_format.json /etc/nginx/
RUN chown -R 999:998 /usr/share/ts /var/log/app_protect /opt/app_protect /etc/app_protect /etc/nginx/nginx.conf /var/
RUN chmod -R 777 /var/run && chmod 777 -R /var/cache/

COPY etc/nginx.conf /etc/nginx/
#COPY etc/example.com.conf /etc/nginx/conf.d/
COPY etc/status_api.conf /etc/nginx/conf.d/
COPY etc/waf /etc/nginx/waf

USER 999

EXPOSE 8080 443 9090

COPY entrypoint.sh /tmp

CMD ["sh", "/tmp/entrypoint.sh"]
