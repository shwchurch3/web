#!/bin/bash

. ~/.bashrc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


cronScriptPath=/etc/cron.d/hugo-sync
cronScriptEnv=/etc/cron.d/hugo-sync.env.sh
env > ${cronScriptEnv}
cat ${cronScriptEnv}

hugoGithubRoot=/home/ec2-user/hugo/github
syncFile=${hugoGithubRoot}/t5/bin/sync.sh 
logPath=${hugoGithubRoot}/sync.log

scriptToRun="source ${cronScriptEnv}; /bin/bash ${syncFile} > ${logPath} 2>&1"
echo "1 14 * * * root  ${scriptToRun}" > ${cronScriptPath}
echo "1 21 * * 6 root  ${scriptToRun}" > "${cronScriptPath}_1"

cat ${cronScriptPath}
cat ${cronScriptPath}_1

service crond restart
echo "Crontab restart, new PID: $(pgrep cron)"
echo "sudo tail -f  /var/log/cron*"
