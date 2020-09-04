#!/bin/bash
if [[ -n "${1}" ]] && cat "${1}"; then
	source "${1}"
else
	echo "Config file Required"
	exit 1
fi
export end=$(wget -qO- "https://comic.naver.com/webtoon/list.nhn?titleId=""${titleid}" | grep "/webtoon/detail.nhn?titleId=${titleid}&no=" | head -n 1 | sed 's/<a href="\/webtoon\/detail.nhn?//' | sed 's/titleId.*&no=//' | sed 's/&weekday.*//' | sed 's/^[ \t]*//')
sed -i "s/begin=.*/begin="${end}"/" "$(realpath "${1}")"
sed -i "s/end=.*/end="$((end+1))"/" "$(realpath "${1}")"
exit 0
