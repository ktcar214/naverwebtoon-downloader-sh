#! /bin/bash
if [[ -z ${1} ]]; then
	echo NaverWebtoon BGM Downloader: bgm.sh titleid
	exit 1
fi
export titleid="${1}"
export url="https://m.comic.naver.com/webtoon/detail.nhn?titleId="${titleid}"&no="${c}""
export name=$(wget -qO- 'https://comic.naver.com/webtoon/list.nhn?titleId='"${titleid}" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: :: 네이버 만화)?\s*<\/title/si')
export end=$(wget -qO- "https://comic.naver.com/webtoon/list.nhn?titleId=""${titleid}" | grep "/webtoon/detail.nhn?titleId=${titleid}&no=" | head -n 1 | sed 's/<a href="\/webtoon\/detail.nhn?//' | sed 's/titleId.*&no=//' | sed 's/&weekday.*//' | sed 's/^[ \t]*//')
##begin
echo =====================
echo name = ${name}
echo end = ${end}
echo dir = $(pwd)
echo =====================
export c=1
while((${c}<=${end}));
#echo ${url}
do export bgmurl="$(wget -qO- "https://m.comic.naver.com/webtoon/detail.nhn?titleId="${titleid}"&no="${c}"" | grep bgmUrl | sed  "s/'//g" | sed "s/bgmUrl: //" | sed "s/,//" | sed 's/^[ \t]*//')"
	#echo ${bgmurl}
	if [[ -z ${bgmurl} ]]; then
		echo no bgm found in title no.${c} out of ${end}
		((c++))
		continue;
	fi
	wget  --quiet\
		-U "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0"\
		-O "${name}"-"${c}".mp3 "https://image-comic.pstatic.net"${bgmurl}""
	echo bgm for title no. ${c} downloaded. ${c}/${end}
	((c++))
done
