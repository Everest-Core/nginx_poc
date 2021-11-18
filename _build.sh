sudo docker rm -f nap-santander
sudo docker rmi cavalen/nap-santander

#sudo docker build --progress=plain -t cavalen/nap-santander .
sudo docker build -t cavalen/nap-santander .
sudo docker run --name nap-santander -p 8443:443 -p 8080:80 -p 9090:9090 -d --mount type=bind,source="$(pwd)"/etc/nginx.conf,target=/etc/nginx/nginx.conf --mount type=bind,source="$(pwd)"/etc/example.com.conf,target=/etc/nginx/conf.d/example.com.conf --mount type=bind,source="$(pwd)"/etc/status_api.conf,target=/etc/nginx/conf.d/status_api.conf -v "$(pwd)"/etc/waf:/etc/nginx/waf cavalen/nap-santander

sudo docker logs nap-santander
sudo docker inspect nap-santander
sudo docker exec -it nap-santander bash
