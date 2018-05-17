SSH_ASKPASS_SCRIPT=/tmp/ssh-askpass-script
SSH_PAYLOAD=/tmp/.payload.tmp
cat > $${SSH_ASKPASS_SCRIPT} <<EOL
#!/bin/bash
echo "${cisco_password}"
EOL
chmod u+x $${SSH_ASKPASS_SCRIPT}
export DISPLAY=:0
export SSH_ASKPASS=$${SSH_ASKPASS_SCRIPT}
SSH_OPTIONS="-oLogLevel=error -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"
cat > $${SSH_PAYLOAD} <<EOL
${cisco_commands}
EOL
SSH_EXEC_SCRIPT=/tmp/ssh-exec
cat > $${SSH_EXEC_SCRIPT} <<EOL
#!/bin/sh
while read line; do setsid ssh $${SSH_OPTIONS} ${cisco_user}@${cisco_hostname} "\$line"; done < $${SSH_PAYLOAD}
EOL
chmod u+x $${SSH_EXEC_SCRIPT}
sh $${SSH_EXEC_SCRIPT}
