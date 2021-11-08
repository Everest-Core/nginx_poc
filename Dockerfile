# For RHEL ubi7:
FROM centos
# Download certificate and key from the customer portal (https://my.f5.com)
# and copy to the build context:

#COPY nginx-repo.crt nginx-repo.key /etc/ssl/nginx/
RUN echo "build patitas"
# Install prerequisite packages:
RUN yum -y install wget ca-certificates
# Add NGINX Plus repo to Yum:
RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.repo
# Enable Yum repositories to pull App Protect dependencies:
#RUN subscription-manager register --org=${RHEL_ORGANIZATION} --activationkey=${RHEL_ACTIVATION_KEY} \
#&&yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional rhel-7-
#server-optional-rpms \
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
&& yum clean all
# Install NGINX App Protect:
RUN yum -y install app-protect app-protect-attack-signatures \
&& yum clean all \
&& rm -rf /var/cache/yum \
&& rm -rf /etc/ssl/nginx \
&& subscription-manager unregister
# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
&& ln -sf /dev/stderr /var/log/nginx/error.log
# Copy configuration files:
#COPY nginx.conf custom_log_format.json /etc/nginx/
COPY entrypoint.sh /root/
CMD ["sh", "/root/entrypoint.sh"]
