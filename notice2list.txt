curl "${1}" | grep -Eo "https\:\/\/comic.naver.com\/webtoon\/list.nhn\?titleId\=.[0-9][0-9][0-9][0-9][0-9]" | sed 's/https.*\=//' > list
