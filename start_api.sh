#!/bin/bash
sed -i -e 's/{CPU_COUNT}/'"$CPU_COUNT"'/g' /api-li3ds/conf/api_li3ds.uwsgi.yml
sed -i -e 's/{API_KEY}/'"$API_KEY"'/g' /api-li3ds/conf/api_li3ds.yml
exec uwsgi --yaml /api-li3ds/conf/api_li3ds.uwsgi.yml
