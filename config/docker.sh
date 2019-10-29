if which docker &>/dev/null && docker stats --no-stream &>/dev/null; then

  proxy_status=$(docker inspect nginx-proxy -f '{{.State.Status}}' 2>/dev/null)
  if [ "$proxy_status" == '' ]; then
    info "Creating nginx-proxy container..."
    docker run -d --name nginx-proxy \
                  --restart always \
                  -p 80:80 \
                  -p 443:443 \
                  -v /var/run/docker.sock:/tmp/docker.sock:ro \
                  jwilder/nginx-proxy \
                  &>$LOGFILE || abort "Error creating nginx-proxy container!"
  elif [ "$proxy_status" == 'exited' ]; then
    info "Starting nginx-proxy container..."
    docker start nginx-proxy &>$LOGFILE || abort "Error starting nginx-proxy container!"
  fi

  if ! docker network inspect nginx-proxy-network &>/dev/null; then
    info "Creating nginx-proxy-network..."
    docker network create nginx-proxy-network &>$LOGFILE || abort "Error creating nginx-proxy-network!"
  fi
  docker network connect nginx-proxy-network nginx-proxy &>/dev/null

  good "nginx-proxy container is configured..."

else

  warn "Skipping Docker configuration; please start Docker.app and re-run $0."

fi
