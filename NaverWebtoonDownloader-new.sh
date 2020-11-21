#! /bin/bash
## Code refactored by ktcar214. 2020.08.04
## Original code by nursyah
## Original Repo: https://github.com/nursyah21/webtoon-downloader
## GNU GPL v3

##help
if [[ ${1} == "--help" ]] || [[ ${1} == "-h" ]] || [[ -z "${1}" ]]; then
	echo "usage: Naverwebtoondownloader.sh titleId START END(end) Folder(default) (Foldername_autogen) [PDF] (compress - 0 or 1)";
	exit;
fi
export titleid="${1}"
export begin="${2}"
export end="${3}"
export folder="${4}"
export foldername_autogen="${5}"
export pdf="${6}"
export compress="${7}"
#if [[ -z ${begin} ]]; then
#	export begin="1"
#fi
# retrieve end
if [[ ${end} == "end" ]]; then
	export end=$(wget -qO- "https://comic.naver.com/webtoon/list.nhn?titleId=""${titleid}" | grep "/webtoon/detail.nhn?titleId=${titleid}&no=" | head -n 1 | sed 's/<a href="\/webtoon\/detail.nhn?//' | sed 's/titleId.*&no=//' | sed 's/&weekday.*//' | sed 's/^[ \t]*//')
	#	echo "${end}"
fi
# make folder
export name=$(wget -qO- 'https://comic.naver.com/webtoon/list.nhn?titleId='"${titleid}" | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: :: 네이버 만화)?\s*<\/title/si')

if [[ ${foldername_autogen} == 1 ]] && [[ -n "${folder}" ]] && [[ "${folder}" != "default" ]]; then
	if [[ ${folder} == */ ]]; then
		mkdir "$folder""$name" 
		cd "$folder""$name";
	else
		mkdir "$folder"/"$name"
		cd "$folder"/"$name";
	fi

elif [[ -z "${folder}" ]] || [[ "${folder}" == "default" ]]; then
	mkdir "$name" 
	cd "$name"
else
	mkdir "$folder" 
	cd "$folder"
fi
# download html
#pwd
echo ====================BEGIN======================
echo start time: "$(date +%c)"
echo location: "$(pwd)"
echo webtoon titleID: ${titleid}
echo webtoon name: "${name}"
echo pdf: "${pdf}"
echo begin point: ${begin}
echo end: ${end}
echo compress: ${compress}
echo ====================BEGIN======================
c=${begin};
while((${c}<=${end}));
do echo "https://comic.naver.com/webtoon/detail.nhn?titleId=${titleid}&no=""${c}" >> down.txt;
	((c++));
done;
# make download list using sed & grep
c=${begin};
while read p;
do wget --quiet -U mozilla -nv -O temp_"$c" "$p";
	grep "comic content" temp_''"$c"'' | sed "s/<img src=\"//" | sed "s/\".*//" | sed 's/^[ \t]*//' >> ''"$c"'';
#	grep "comic content" temp_''"$c"'' | sed "s/<img src=\"//" | sed "s/\.gif.*/.gif/" | sed 's/^[ \t]*//' >> ''"$c"'';
	echo $(date +%c) link creation: "${c}" out of ${end}
	((c++));
done<down.txt;
rm down.txt temp*;
echo $(date +%c) "create link complete";
#download images
c=${begin};
while(($c<=${end}));
do s=1
	while read p;
	do wget -U "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0" \
		-c  --quiet --retry-connrefused --timeout=0.5 --waitretry=0 --tries=30 \
		-O "$c"-"$s".jpg "$p";
			((s++));
		done<"${c}"
		rm "${c}";
		echo $(date +%c) "${c}/${end} downloaded"
		((c++));
	done;
	# padding 0 for numerical file sorting
	# cut no.
	for f in *-[0-9].jpg ; 
	do mv "${f}" "${f/-/-0}"; 
	done;
	c=${begin};
	for f in *.jpg;
	do case $f in
		*-[0-9].jpg ) mv "${f}" "$(echo "${f}" | sed 's/-/-000/')";;
		*-[0-9][0-9].jpg ) mv "${f}" "$(echo "${f}" | sed 's/-/-00/')";;
		*-[0-9][0-9][0-9].jpg ) mv "${f}" "$(echo "${f}" | sed 's/-/-0/')";;
	esac
done
if [[ ${pdf} == "PDF" ]] || [[ ${pdf} == 1 ]]; then
	if [[ ! -d "pdf" ]]; then
		mkdir ./pdf;
	fi
	while(($c<=${end}));
	do img2pdf "${c}"-*.jpg --output "$c".pdf; 
		echo "PDF: ${c}/${end} complete"
		((c++));
	done
	for f in [0-9].pdf;
	do mv "$f" $(printf %02d%s "${f%.*}" "${a##*.}").pdf;
	done;
	echo $(date +%c) "moving pdf"
	mv *.pdf ./pdf/
fi
# clean up
echo "cleaning up images"
if [[ ! -d "img" ]]; then
	mkdir ./img;
fi
for f in *.jpg;
do case $f in
	[0-9]-*.jpg ) mv "${f}" "$(echo "${f}" | sed 's/^/000/')";;                   
	[0-9][0-9]-*.jpg ) mv "${f}" "$(echo "${f}" | sed 's/^/00/')";;
	[0-9][0-9][0-9]-*.jpg ) mv "${f}" "$(echo "${f}" | sed 's/^/0/')";;
esac

done
mv *.jpg ./img;
if [[ ${compress} == 1 ]]; then
	echo compressing using 7z
	7z a "$(pwd)" -o"$(pwd)"/../
fi
echo ====================END====================
echo end time: "$(date +%c)"
echo location: "$(pwd)"
echo webtoon titleID: ${titleid}
echo webtoon name: "${name}"
echo pdf: "${pdf}"
echo begin point: ${begin}
echo end: ${end}
echo compressed: ${compress}
echo ====================END====================
exit 0
