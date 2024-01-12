#!/bin/bash

bash /app/update.sh update_config
bash /app/update.sh update_policy

crontab -r
echo -e "${CRON} bash /app/update.sh update_config && bash /app/update.sh update_policy" >> /tmp/crontab.list
echo "Set crontab to system..."
crontab /tmp/crontab.list
echo "Current crontab is:"
crontab -l
rm -f /tmp/crontab.list

exec crond -f