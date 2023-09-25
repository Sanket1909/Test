
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


cd "$SCRIPT_DIR"


while getopts ":v:" opt; do
  case $opt in
    v)
      VERBOSE=true
      XML_PATH="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done


run_application() {
  if [ "$VERBOSE" = true ]; then
    # Run the application with the -v flag to print keys to Redis
    node main.js -v "$XML_PATH"
  else
    # Run the application without the -v flag
    node main.js "$XML_PATH"
  fi
}

# Check if Docker is running
if ! docker --version > /dev/null 2>&1; then
  echo "Docker is not installed or not running."
  exit 1
fi

# Check if Redis container is running
REDIS_CONTAINER_NAME="my-xml-to-redis-redis-1"
if ! docker ps --format '{{.Names}}' | grep -q "$REDIS_CONTAINER_NAME"; then
  echo "Redis container ($REDIS_CONTAINER_NAME) is not running. Starting Redis container..."
  docker-compose up -d redis
fi


run_application

