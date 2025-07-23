Attempt to make a multi-arch version so I can run the same image on multiple machines.

To build

  Clone repository

  cd adguardhome-unbound-redis

  docker buildx build --platform linux/amd64,linux/arm64 -t my_adguard:latest .


Copy image to another machine

docker save <image> | gzip | DOCKER_HOST=ssh://user@remotehost docker load 
