.PHONY: gogo build stop-services start-services truncate-logs bench kataribe

gogo: stop-services build truncate-logs start-services bench

build:
	cd go && make all

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isucholar.go.service
	ssh isucon@172.31.23.8 "sudo systemctl stop mysql"

start-services:
	ssh isucon@172.31.23.8 "sudo systemctl start mysql"
	sudo systemctl start isucholar.go.service
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	ssh isucon@172.31.23.8 "sudo truncate --size 0 /var/log/mysql/mysql-slow.log"

kataribe:
	cd ../ && sudo cat /var/log/nginx/access.log | ./kataribe

bench:
	ssh isucon@172.31.28.181 "cd benchmarker && ./bin/benchmarker -target=sub.mishima.tokyo -tls"

save-log: TS=$(shell date "+%Y%m%d_%H%M%S")
save-log:
	mkdir /home/isucon/logs/$(TS)
	sudo  cp -p /var/log/nginx/access.log  /home/isucon/logs/$(TS)/access.log
	ssh isucon@172.31.23.8 "sudo  cp -p /var/log/mysql/mysql-slow.log /home/isucon/mysql-slow.log && sudo chmod -R 777 mysql-slow.log"
	scp isucon@172.31.23.8:~/mysql-slow.log /home/isucon/logs/$(TS)/mysql-slow.log
	sudo chmod -R 777 /home/isucon/logs/*
sync-log:
	scp -C kataribe.toml ubuntu@172.31.43.190:~/
	rsync -av -e ssh /home/isucon/logs ubuntu@172.31.43.190:/home/ubuntu
analysis-log:
	ssh ubuntu@172.31.43.190 "sh push_github.sh"
gogo-log: save-log sync-log analysis-log
