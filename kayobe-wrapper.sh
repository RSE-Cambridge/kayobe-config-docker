export JENKINS_URL=http://10.60.150.1
export JENKINS_USER=admin
export COOKIE_JAR=/tmp/cookies
export JOB=kayobe-command-run

function kayobe {
  CMD="$*"
  JSON=$(printf '{"parameter": [{"name":"COMMAND", "value":"kayobe %s"}]}' "$CMD")
  echo Posting: $JSON to $JENKINS_URL/job/$JOB/build
  JENKINS_CRUMB=$(curl --silent --cookie-jar $COOKIE_JAR $JENKINS_URL'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u $JENKINS_USER:$JENKINS_TOKEN)
  curl -X POST $JENKINS_URL/job/$JOB/build \
    --user $JENKINS_USER:$JENKINS_TOKEN \
    -H $JENKINS_CRUMB  --cookie $COOKIE_JAR \
    --form json="$JSON"
}
