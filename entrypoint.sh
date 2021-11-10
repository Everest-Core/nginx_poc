#!/bin/bash
/opt/app_protect/bin/bd_agent &
/usr/sbin/nginx -g 'daemon off;'
