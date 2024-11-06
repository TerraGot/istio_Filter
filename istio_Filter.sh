#!/bin/bash

INPUT_FILE="istio.log"

MAX_REQUEST_BYTES=0
MAX_RESPONSE_BYTES=0
MAX_WORKTIME=0
MAX_RESPONSE_TIME=0

MAX_REQUEST_LINE=""
MAX_RESPONSE_LINE=""
MAX_WORKTIME_LINE=""
MAX_RESPONSE_TIME_LINE=""

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
											done < "$INPUT_FILE"

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
