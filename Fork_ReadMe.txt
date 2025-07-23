Attempt to make a arm version that I can run on a RaspberryPi.

To build

  Clone repository

  cd adguardhome-unbound-redis

  docker buildx build -t my_adguard:latest .


Copy image to another machine (assumes passwordless login)

docker save <image> | gzip | DOCKER_HOST=ssh://user@remotehost docker load 
