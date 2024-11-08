#!/bin/bash

INPUT_FILE="istio.log"
ERRORS_FILE="ERRORS.log"
VALID_STATUS_CODE=(200 201 202 203 204 205 206 207 208 226)

MAX_REQUEST_BYTES=0
MAX_RESPONSE_BYTES=0
MAX_WORKTIME=0
MAX_RESPONSE_TIME=0
MAX_REQUEST_LINE=""
MAX_RESPONSE_LINE=""
MAX_WORKTIME_LINE=""
MAX_RESPONSE_TIME_LINE=""

Resolve_errors() {
    echo "������ 5xx" > "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 5[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    
    echo "������ 4xx" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 4[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    
    echo "��������� 3xx" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 3[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
}
while IFS= read -r line; do
		  REQUEST_BYTES=$(echo "$line" | cut -d' ' -f9)
		  RESPONSE_BYTES=$(echo "$line" | cut -d' ' -f10)
		  WORKTIME=$(echo "$line" | cut -d' ' -f11)
		  RESPONSE_TIME=$(echo "$line" | cut -d' ' -f12)

			if [ $REQUEST_BYTES -gt $MAX_REQUEST_BYTES ]; then
				MAX_REQUEST_BYTES=$REQUEST_BYTES
				MAX_REQUEST_LINE=$line
				fi
			if [ $RESPONSE_BYTES -gt $MAX_RESPONSE_BYTES ]; then
				MAX_RESPONSE_BYTES=$RESPONSE_BYTES
	        		        MAX_RESPONSE_LINE=$line
				fi
		        if [ $WORKTIME -gt $MAX_WORKTIME ]; then
				MAX_WORKTIME=$WORKTIME
	 	                MAX_WORKTIME_LINE=$line
				 fi
				if [ $RESPONSE_TIME -gt $MAX_RESPONSE_TIME ]; then
			          MAX_RESPONSE_TIME=$RESPONSE_TIME
	       			  MAX_RESPONSE_TIME_LINE=$line
				   fi
    				if [[ ! " ${VALID_STATUS_CODE[@]} " =~ " ${STATUS_CODE} " ]]; then
        				echo "$line" >> "$ERRORS_FILE"
    					fi
					done < "$INPUT_FILE"
Resolve_errors

echo "Самый тяжелый отправленный запрос - "
echo "$MAX_REQUEST_LINE"
echo ""
echo "Самый тяжелый полученный запрос - "
echo "$MAX_RESPONSE_LINE"
echo ""
echo "Самый долго обработанный запрос - "
echo "$MAX_WORKTIME_LINE"
echo ""
echo "Самый долгий респонс - "
echo "$MAX_RESPONSE_TIME_LINE"