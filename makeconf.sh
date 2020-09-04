#!/bin/bash
# for use with NaverWebtoondownloader.sh
# creates config file for begin=1, end=retrieve, foldername_autogen=1, folder=/home/ubuntu/webtoon/
titleid="${1}"
name=$(wget -qO- 'https://comic.naver.com/webtoon/list.nhn?titleId='"${titleid}" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: :: 네이버 만화)?\s*<\/title/si')

echo -e "titleid="${titleid}"\nbegin=1\nend=retrieve\nfolder=/home/ubuntu/webtoon/\nfoldername_autogen=1\npdf=PDF" > "${name}".config
exit 0

