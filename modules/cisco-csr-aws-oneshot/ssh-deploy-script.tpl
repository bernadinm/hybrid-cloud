WORKDIR=$(mktemp -d $PWD/cisco_csr_config_XXXXXXXXX)
SSH_SWITCH_LIST=$WORKDIR/switch
touch $${WORKDIR}/status
cat > $${SSH_SWITCH_LIST} <<EOL
${cisco_hostname}
EOL
SSH_PAYLOAD=$${WORKDIR}/commands
cat > $${SSH_PAYLOAD} <<EOL
${cisco_commands}
EOL
SSH_EXEC_SCRIPT=/$${WORKDIR}/ssh-exec
cat > $${SSH_EXEC_SCRIPT} <<EOL
#!/bin/sh
COMMAND="docker run -v \$PWD:\$PWD -it bernadinm/crassh:1.0.1 python crassh.py -s $SSH_SWITCH_LIST -c $SSH_PAYLOAD -U ${cisco_user} -P ${cisco_password} -Q -q"
echo "please wait...Cisco SSH Agent starts ~5 mins...";
while [ 0 -eq \$(grep -c done $${WORKDIR}/status) ]; do \$COMMAND | sed -e 's/Connection Failed: timed out/waiting for Cisco SSH agent to start.../g' | sed -e 's/Unexpected.\+/waiting for Cisco SSH agent to start.../g' | tee $${WORKDIR}/status ; grep done $${WORKDIR}/status && break || sleep 20; done
rm -fr $${WORKDIR}
EOL
chmod u+x $${SSH_EXEC_SCRIPT}
sh $${SSH_EXEC_SCRIPT}
