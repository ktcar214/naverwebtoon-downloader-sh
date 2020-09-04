#! /bin/bash
#check root status
#if ! touch /root/test %% rm /root/test; then
#	echo "Insufficient permission"
#	exit -1
#fi
# retrieve weekday
if cat "${1}"; then
	source ${1}
	realpath=$(realpath "${1}")
else
	echo "Config file required"
	exit 1
fi
week=$(wget -O- "https://comic.naver.com/webtoon/list.nhn?titleId=${titleid}" | grep 'class="on"' | grep week= | sed "s/.*nhn?//" | sed "s/\">.*//" | sed "s/week=//")

case "${week}" in 
	mon ) cron_weekday=1;;
	tue ) cron_weekday=2;;
	wed ) cron_weekday=3;;
	thu ) cron_weekday=4;;
	fri ) cron_weekday=5;;
	sat ) cron_weekday=6;;
	sun ) cron_weekday=0;;
esac

crontab -l >crontab.txt
echo "0 10 * * ${cron_weekday} nvr-wtn-dl config ${realpath} progress >/dev/null 2>&1" >> crontab.txt && crontab crontab.txt && rm crontab.txt
echo "done"
exit 0
