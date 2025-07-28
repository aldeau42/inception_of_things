all:
	sh ./provision-server.sh

docker:
	docker compose up -d

clone:
	git clone http://localhost:9182/root/aderouin.git
	
copy:
	cp -r ../P3 aderouin/

git:
	git add .
	git commit -m "copy P3"
	git push
	
clean:
	@if [ -n "$$(docker ps -aq)" ]; then docker rm -f $$(docker ps -aq); fi
	docker system prune -a --volumes -f


