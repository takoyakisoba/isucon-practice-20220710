.PHONY: gogo build stop-services start-services truncate-logs bench

gogo: stop-services build truncate-logs start-services bench

build:
	make -C go all

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isucholar.go.service
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sudo systemctl start isucholar.go.service
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/log/mysql/mysql-slow.log 

kataribe:
	cd ../ && sudo cat /var/log/nginx/access.log | ./kataribe

bench:
	ssh isucon@172.31.28.181 "cd benchmarker && ./bin/benchmarker -target=sub.mishima.tokyo -tls"
