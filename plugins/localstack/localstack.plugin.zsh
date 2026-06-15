# CLI support for LOCALSTACK interaction
#
# See README.md for details
lsk() {
  case $1 in
    sqs-send)
      shift
      sqs-send "$@"
      ;;
    *)
      echo "Command not found: $1"
      return 1
      ;;
  esac
}

# Send SQS function
#
# This function sends a given message in sqs to a given queue, when used Localstack
#
# Use:
#   sqs-send <queue> <message>
#
# Parameters
#   <queue> A given queue
#   <message> A content of message em json archive
#
# Example
#   sqs-send user user.json
sqs-send(){
  if [ -z "$1" ] || [ -z "$2" ]; then
	  echo "Use: sqs-send <queue> <payload>"
	  return 1
  fi

  local queue="$1"
  local payload_file="$2"

  if [ ! -f "$payload_file" ]; then
	  echo "Error: payload file not found: $payload_file" >&2
	  return 1
  fi

  if [ ! -r "$payload_file" ]; then
	  echo "Error: payload file is not readable: $payload_file" >&2
	  return 1
  fi

  local payload
  payload="$(cat "$payload_file")"

  curl -fsS -X POST "http://localhost:4566/000000000000/$queue" \
	  -d "Action=SendMessage" \
	  --data-urlencode "MessageBody=$payload"
  local status=$?

  if [ "$status" -ne 0 ]; then
	  echo "Error: failed to send message to queue '$queue' (curl exit $status)" >&2
	  return "$status"
  fi
}