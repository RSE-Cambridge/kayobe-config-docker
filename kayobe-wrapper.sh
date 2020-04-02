export JENKINS_URL=http://10.60.150.1
export JENKINS_USER=admin
export COOKIE_JAR=/tmp/cookies
export JOB=kayobe-command-run

function kayobe {
  CMD=( "kayobe" "${@}" )
  # We pass through json and groovy escaping on the way to being executed. 
  # It is easier just to base64 encode the command and decode it on the 
  # other side. Otherwise you have issues with commands like: 
  # kayobe overcloud host command run --command "echo 'hello world'"
  printf -v ESCAPED "%q " "${CMD[@]}"
  ENCODED=$(echo "$ESCAPED" | base64 -w 0)
  echo "The encoded string is:"
  echo "${ENCODED}"
  JSON=$(printf '{"parameter": [{"name":"COMMAND", "value":"bash -c '"'"'export CMD=$(echo %s | base64 -d); echo $CMD; echo $CMD | bash\'"'"'"}]}' "$ENCODED")
  echo Posting: $JSON to $JENKINS_URL/job/$JOB/build
  JENKINS_CRUMB=$(curl --silent --cookie-jar $COOKIE_JAR $JENKINS_URL'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u $JENKINS_USER:$JENKINS_TOKEN)
  curl -X POST $JENKINS_URL/job/$JOB/build \
    --user $JENKINS_USER:$JENKINS_TOKEN \
    -H $JENKINS_CRUMB  --cookie $COOKIE_JAR \
    --form json="$JSON"
}
