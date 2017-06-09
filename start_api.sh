#!/bin/bash
sed -i -e 's/{API_KEY}/'"$API_KEY"'/g' /api-li3ds/conf/api_li3ds.yml
python3 /api-li3ds/api_li3ds/wsgi.py
