#!/bin/bash

# Параметры
INPUT_FILE="istio.log"
ERRORS_FILE="ERRORS.log"
VALID_STATUS_CODE="200 201 202 203 204 205 206 207 208 226"

# Функция для измерения времени выполнения
Measure_execution_time() {
    END_TIME=$(date +%s%3N)  # Получаем текущее время в миллисекундах
    EXECUTION_TIME=$((END_TIME - START_TIME))  # Вычисляем разницу
    echo "Script execution time: $EXECUTION_TIME milliseconds."  # Выводим в миллисекундах
}

# Функция для проверки, является ли запрос REST или TCP
is_rest_request() {
    local request="$1"
    
    # Проверяем наличие HTTP-методов и отсутствие дополнительных параметров
    if [[ "$request" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]\"(GET|POST|PUT|DELETE|PATCH|OPTIONS|HEAD) ]]; then
        # Проверяем, что строка не содержит "inbound" или "outbound"
        if [[ ! "$request" =~ inbound|outbound ]]; then
            echo "REST Request: $request"
            return 0  # Успешно распознано как REST-запрос
        else
            echo "Not a REST Request (TCP): $request"
            return 1  # Определено как TCP-запрос
        fi
    else
        echo "Not a REST Request: $request"
        return 1  # Определено как не REST-запрос
    fi
}


START_TIME=$(date +%s%3N)

{
    echo "Ошибки 5xx" > "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 5[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"

    echo "Ошибки 4xx" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 4[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"

    echo "Редиректы 3xx" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
    grep -E '^[^ ]+ [^ ]+ [^ ]+ [^ ]+ 3[0-9]{2} ' "$INPUT_FILE" >> "$ERRORS_FILE"
    echo "===================" >> "$ERRORS_FILE"
}

# Обработка файла с помощью awk для извлечения максимальных значений
awk -v valid_codes="$VALID_STATUS_CODE" -v max_req=0 -v max_resp=0 -v max_work=0 -v max_resp_time=0 '
{
    # Проверяем, является ли строка TCP-запросом
    if ($0 ~ /inbound|outbound/) {
        next  # Пропускаем TCP-запросы
    }

    status_code = $8;
    request_bytes = $9;
    response_bytes = $10;
    worktime = $11;
    response_time = $12;

    if (request_bytes > max_req) {
        max_req = request_bytes;
        max_req_line = $0;  # Исправлено: убран лишний пробел
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
        print "РЎР°РјС‹Р№ С‚СЏР¶РµР»С‹Р№ РѕС‚РїСЂР°РІР»РµРЅРЅС‹Р№ Р·Р°РїСЂРѕСЃ - "
        print ""
	print max_req_line;
	print ""
    }
    if (max_resp_line) {
        print "РЎР°РјС‹Р№ С‚СЏР¶РµР»С‹Р№ РїРѕР»СѓС‡РµРЅРЅС‹Р№ Р·Р°РїСЂРѕСЃ - "
	print ""
        print max_resp_line;
	print ""
    }
    if (max_work_line) {
        print "РЎР°РјС‹Р№ РґРѕР»РіРѕ РѕР±СЂР°Р±РѕС‚Р°РЅРЅС‹Р№ Р·Р°РїСЂРѕСЃ - "
        print ""
	print max_work_line;
	print ""
    }
    if (max_resp_time_line) {
        print "РЎР°РјС‹Р№ РґРѕР»РіРёР№ СЂРµСЃРїРѕРЅСЃ - "
	print ""
        print max_resp_time_line;
	print ""
    }
}' "$INPUT_FILE"


Measure_execution_time