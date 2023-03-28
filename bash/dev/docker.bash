function docker__reset {
  docker container prune -f
  docker volume prune -f
  for vol in $(docker volume ls -q); do
    docker volume rm "$vol"
  done
}
