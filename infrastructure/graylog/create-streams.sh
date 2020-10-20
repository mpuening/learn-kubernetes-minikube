#!/bin/bash

GRAYLOG_URL="http://admin:password@192.168.64.5:30003"

GRAYLOG_GELF_HTTP_INPUT='
{
  "type": "org.graylog2.inputs.gelf.http.GELFHttpInput",
  "title": "Gelf HTTP Input",
  "global": "true",
  "configuration": {
    "port": 12201,
    "bind_address": "0.0.0.0"
  }
}'

GRAYLOG_STREAM_TEMPLATE='
{
  "title": "NAME Stream",
  "description": "NAME Messages",
  "index_set_id": INDEX_SET_ID,
  "rules": [{
    "field": "stream",
    "value": "NAME",
    "type": 2,
    "inverted": false
  }]
}'

# Commands if you need help determining which input type to use
# INPUT_TYPES=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG_URL}/api/system/inputs/types 2> /dev/null)
# echo $INPUT_TYPES | jq --color-output

EXISTING_INPUTS=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG_URL}/api/system/inputs 2> /dev/null)

if [ $(echo $EXISTING_INPUTS | grep -c "GELF HTTP") != "1" ]; then
	echo "Creating GELF HTTP Input..."
	curl -X POST -H "X-Requested-By: admin" -H "Content-Type: application/json" -d "${GRAYLOG_GELF_HTTP_INPUT}" ${GRAYLOG_URL}/api/system/inputs > /dev/null
else
	echo "Appears GELF HTTP Input already exists..."
fi

EXISTING_INDEX_SETS=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG_URL}/api/system/indices/index_sets 2> /dev/null)
DEFAULT_INDEX_SET_ID=`echo $EXISTING_INDEX_SETS | jq '.index_sets[] | select(.title=="Default index set")' | jq '.id'`

EXISTING_STREAMS=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG_URL}/api/streams 2> /dev/null)
#echo $EXISTING_STREAMS | jq --color-output
#echo $EXISTING_STREAMS | jq '.streams[] | select(.title=="All messages")' | jq '.id' --color-output

# Example Stream
if [ $(echo $EXISTING_STREAMS | grep -c "Example Stream") != "1" ]; then
	echo "Creating Example Stream..."

	GRAYLOG_EXAMPLE_STREAM=`echo $GRAYLOG_STREAM_TEMPLATE | sed "s/NAME/Example/g" | sed "s/INDEX_SET_ID/$DEFAULT_INDEX_SET_ID/g"`
	curl -s -X POST -H "X-Requested-By: admin" -H "Content-Type: application/json" -d "${GRAYLOG_EXAMPLE_STREAM}" ${GRAYLOG_URL}/api/streams > /dev/null

	STREAM_ID=$(curl -s -X GET -H "Content-Type: application/json" ${GRAYLOG_URL}/api/streams | jq '.streams[] | select(.title=="Example Stream")' | jq '.id' | tr '"' '\0')
	curl -s -X POST -H "X-Requested-By: admin" ${GRAYLOG_URL}/api/streams/$STREAM_ID/resume > /dev/null
else
	echo "Appears example stream already exists..."
fi


