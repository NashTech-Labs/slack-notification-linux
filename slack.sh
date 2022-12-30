#!/bin/bash
function send_slack_notification(){

  local message=$1
  SLACK_URL="${SLACK_WEBHOOK}"
  TITLE="${SLACK_TITLE}"
  COLOR='good'
  EXIT_STATUS=$2

  if [ ${EXIT_STATUS} -ne 0 ]; then
    COLOR='danger'
  fi  

  PAYLOAD_SKELETON='{"attachments":[{"title":"","color":"","fields":[{"title":"BUILD_STEP","value":"DB_BACKUP","short":true},{"title":"BUILD_URL","value":"DB_BACKUP","short":false},{"title":"BUILD_STEP_MESSAGE","value":"SUCCESSFULL","short":true}],"footer":"liquibase"}]}'

  UPDATE_PAYLOAD=`echo $PAYLOAD_SKELETON | jq --indent 0 --arg build_label "${BUILDKITE_LABEL}" '.attachments[0].fields[0].value = $build_label'`
  UPDATE_PAYLOAD=`echo $UPDATE_PAYLOAD | jq --indent 0 --arg build_url "${BUILDKITE_BUILD_URL}" '.attachments[0].fields[1].value = $build_url'`
  UPDATE_PAYLOAD=`echo $UPDATE_PAYLOAD | jq --indent 0 --arg title "$TITLE" '.attachments[0].title = $title'`
  UPDATE_PAYLOAD=`echo $UPDATE_PAYLOAD | jq --indent 0 --arg color "$COLOR" '.attachments[0].color = $color'`
  
  echo $UPDATE_PAYLOAD | jq --indent 0 --arg message "$message" '.attachments[0].fields[2].value = $message' > payload.json
  curl -w "%{http_code}\n" -XPOST $SLACK_URL -H 'Content-Type: application/json' -d @payload.json
}

send_slack_notification "message to send" <EXIT_STATUS>