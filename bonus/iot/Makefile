all:
	sh ./install.sh

clean:
	@if [ -n "$$(docker ps -aq)" ]; then docker rm -f $$(docker ps -aq); fi
	docker system prune -a --volumes -f


