#!/bin/bash

# ���������
INPUT_FILE="istio.log"
ERRORS_FILE="ERRORS.log"
VALID_STATUS_CODE="200 201 202 203 204 205 206 207 208 226"

# ������� ��� ��������� ������� ����������
Measure_execution_time() {
    END_TIME=$(date +%s%3N)  # �������� ������� ����� � �������������
    EXECUTION_TIME=$((END_TIME - START_TIME))  # ��������� �������
    echo "Script execution time: $EXECUTION_TIME milliseconds."  # ������� � �������������
}

# ������� ��� ��������, �������� �� ������ REST ��� TCP
is_rest_request() {
    local request="$1"
    
    # ��������� ������� HTTP-������� � ���������� �������������� ����������
    if [[ "$request" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]\"(GET|POST|PUT|DELETE|PATCH|OPTIONS|HEAD) ]]; then
        # ���������, ��� ������ �� �������� "inbound" ��� "outbound"
        if [[ ! "$request" =~ inbound|outbound ]]; then
            echo "REST Request: $request"
            return 0  # ������� ���������� ��� REST-������
        else
            echo "Not a REST Request (TCP): $request"
            return 1  # ���������� ��� TCP-������
        fi
    else
        echo "Not a REST Request: $request"
        return 1  # ���������� ��� �� REST-������
    fi
}


START_TIME=$(date +%s%3N)

{
    echo "������ 5xx" > "$ERRORS_FILE"
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

# ��������� ����� � ������� awk ��� ���������� ������������ ��������
awk -v valid_codes="$VALID_STATUS_CODE" -v max_req=0 -v max_resp=0 -v max_work=0 -v max_resp_time=0 '
{
    # ���������, �������� �� ������ TCP-��������
    if ($0 ~ /inbound|outbound/) {
        next  # ���������� TCP-�������
    }

    status_code = $8;
    request_bytes = $9;
    response_bytes = $10;
    worktime = $11;
    response_time = $12;

    if (request_bytes > max_req) {
        max_req = request_bytes;
        max_req_line = $0;  # ����������: ����� ������ ������
    }
    if (response_bytes > max_resp) {
        max_resp = response_bytes;
        max_resp_line = $0;
    }
    if (worktime > max_work) {
        max_work = worktime;
        max_work_line = $0;
    }
    if (response_time > max_resp_time) {
        max_resp_time = response_time;
        max_resp_time_line = $0;
    }
}
END {
    if (max_req_line) {
        print "Самый тяжелый отправленный запрос - "
        print ""
	print max_req_line;
	print ""
    }
    if (max_resp_line) {
        print "Самый тяжелый полученный запрос - "
	print ""
        print max_resp_line;
	print ""
    }
    if (max_work_line) {
        print "Самый долго обработанный запрос - "
        print ""
	print max_work_line;
	print ""
    }
    if (max_resp_time_line) {
        print "Самый долгий респонс - "
	print ""
        print max_resp_time_line;
	print ""
    }
}' "$INPUT_FILE"


Measure_execution_time