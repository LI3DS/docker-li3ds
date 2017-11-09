#!/bin/bash
/etc/init.d/postgresql start && start_api.sh && /etc/init.d/postgresql stop
