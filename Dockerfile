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

# Copy configuration files:
RUN rm /etc/nginx/nginx.conf
COPY etc/nginx.conf /etc/nginx/
COPY etc/example.com.conf /etc/nginx/conf.d/
COPY etc/status_api.conf /etc/nginx/conf.d/
COPY etc/waf /etc/nginx/waf
COPY entrypoint.sh /root/

RUN chmod o+rwx /var/log/app_protect \
&& chmod o+rwx /var/cache/nginx \
&& chmod o+rwx /opt/app_protect/

EXPOSE 80 443 9090
#STOPSIGNAL SIGTERM
CMD ["sh", "/root/entrypoint.sh"]
