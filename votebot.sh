#/bin/ksh
##Potaje6
#grep 'votes={' log_event_loop_1.log | tail -n 1 |cut -f 2 -d \{ | tr , "\n" | cut -f 2 -d ":" |uniq -c |tr -s [:blank:]
#Pretty much spaghetti coded script to print the votings of both servers, temp fix for the fucking crashes
#This is a totally ShitScript, you are warned

EXEC_DIR=$(dirname $0)
EXEC_NAME=$(basename $0)
#TEMP_DIR=$EXEC_DIR/tmp
SERVER_URL="https://url.to.your.rcon" #unused
SERVER_NAME=Server1
HIST_FILE=$EXEC_DIRh/distory_${SERVER_NAME}
#TEMP_FILE=$TEMP_DIR/${SERVER_NAME}.tmp
TEMP_FILE=$EXEC_DIR/${SERVER_NAME}.tmp
#Add here the webhook of the discord channel
WEBHOOK=https://discord.com/api/webhooks/your_webhook_goes_here
#https://github.com/ChaoticWeg/discord.sh
DISCORD=$EXEC_DIR/discord.sh/discord.sh
LOG_DIR=/hll_rcon_logs_dir
#LOG_FILE=log_event_loop_$i.log

print_uso(){
	                cat <<EOF
        Usage:
        ./$EXEC_NAME [ -u rcon url (something like https://my.cool.rcon.com) -s server name to display in discord ]
EOF
exit
}

for i in 1 2 3
do
	grep 'votes={' ${LOG_DIR}/log_event_loop_$i.log  | tail -n 1 |cut -f 2 -d \{ | tr , "\n" | cut -f 2 -d ":" |tr -s [:blank:] |sed 's/}//' | sed "s/'//g" | sort | uniq -c |sed 's/      //'|sort -n -r -k1 | sed ':a;N;$!ba;s/\n/, /g' |tr -s [:blank:] > ${EXEC_DIR}/Server$i.tmp
	diff ${EXEC_DIR}/Server$i.tmp ${EXEC_DIR}/Server$i.vote > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		mv ${EXEC_DIR}/Server${i}.tmp ${EXEC_DIR}/Server${i}.vote
		MESSAGE=$(cat ${EXEC_DIR}/Server${i}.vote)
		$DISCORD --username Server$i --webhook-url $WEBHOOK --text "$MESSAGE"
	else
		rm -f ${EXEC_DIR}/Server${i}.tmp
		continue
	fi
#	grep 'votes={' ${LOG_DIR}/log_event_loop_$i.log  | tail -n 1 |cut -f 2 -d \{ | tr , "\n" | cut -f 2 -d ":" |tr -s [:blank:] |sed 's/}//' | sed "s/'//g" | sort | uniq -c |sed 's/      //'|sort -n -r -k1 | sed ':a;N;$!ba;s/\n/, /g' |tr -s [:blank:] > Server$i.vote
		#echo $MESSAGE
done

