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
RUN  yum -y install app-protect \
    && yum clean all \
    && rm -rf /var/cache/yum

# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy configuration files:
#COPY nginx.conf custom_log_format.json /etc/nginx/
#COPY entrypoint.sh /root/
USER 999

#CMD ["sh", "/root/entrypoint.sh"]
CMD ["/usr/sbin/nginx"]
