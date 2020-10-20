#!/bin/bash

# Documentation: https://docs.graylog.org/en/3.2/pages/gelf.html

curl -X POST -H 'Content-Type: application/json' -d '{ "stream":"Example Stream", "host": "localhost", "short_message": "A test message", "level": 5 }' 'http://192.168.64.5:30004/gelf'

