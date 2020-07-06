function urlencode() {
 # https://stackoverflow.com/questions/37309551/how-to-urlencode-data-into-a-url-with-bash-or-curl
  python -c 'import urllib, sys; print urllib.quote(sys.argv[1], sys.argv[2])' \
    "$1" "$urlencode_safe"
}

export JENKINS_URL=http://10.41.253.100
export JENKINS_USER=admin
export COOKIE_JAR=/tmp/cookies
export BRANCH=alt1/train
export JOB=kayobe-command-run/job/$(urlencode "$BRANCH")

function kayobe {
  CMD=( "kayobe" "${@}" )
  # Escape for shell
  printf -v ESCAPED "%q " "${CMD[@]}"
  # Escape for json
  JSON=$(python -c 'import json; import sys; print(json.dumps({"parameter": [{"name":"COMMAND", "value": sys.argv[1]}]}))' "$ESCAPED")
  echo Posting: $JSON to $JENKINS_URL/job/$JOB/build
  JENKINS_CRUMB=$(curl --silent --cookie-jar $COOKIE_JAR $JENKINS_URL'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u $JENKINS_USER:$JENKINS_TOKEN)
  curl -X POST $JENKINS_URL/job/$JOB/build \
    --user $JENKINS_USER:$JENKINS_TOKEN \
    -H $JENKINS_CRUMB  --cookie $COOKIE_JAR \
    --form json="$JSON"
}

