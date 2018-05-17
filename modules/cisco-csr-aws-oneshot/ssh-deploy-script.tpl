SSH_SWITCH_LIST=$PWD/.switch
cat > $${SSH_SWITCH_LIST} <<EOL
${cisco_hostname}
EOL
SSH_PAYLOAD=$PWD/.commands
cat > $${SSH_PAYLOAD} <<EOL
${cisco_commands}
EOL
SSH_EXEC_SCRIPT=/tmp/.ssh-exec
cat > $${SSH_EXEC_SCRIPT} <<EOL
#!/bin/sh
docker run -v \$PWD:\$PWD -it bernadinm/crassh python crassh.py -s $SSH_SWITCH_LIST -c $SSH_PAYLOAD -U ${cisco_user} -P ${cisco_password}
EOL
chmod u+x $${SSH_EXEC_SCRIPT}
sh $${SSH_EXEC_SCRIPT}
