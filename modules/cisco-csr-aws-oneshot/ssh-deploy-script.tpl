cat > test <<EOF
${cisco_commands}
EOF
IFS=$'\n'; for i in $(cat test); do expect -c "spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${cisco_user}@${cisco_hostname} \"$${i}\"; expect \"Password:\"; send \"${cisco_password}\r\"; interact"; done
