#! /bin/bash
## Code refactored by ktcar214. 2020.08.04
## Original code by nursyah
## Original Repo: https://github.com/nursyah21/webtoon-downloader
## GNU GPL v3

##help
if [[ ${1} == "--help" ]] || [[ ${1} == "-h" ]] || [[ -z "${1}" ]]; then
	echo "usage: Naverwebtoondownloader.sh -t titleId -b START -e END(end) -l Folder(default) --subfolder --pdf --compress"
	echo "-t (--titleid) : title ID of the target webtoon."
	echo "-b (--begin) : beginning point. default : 1"
	echo "-e (--end) : ending point. Program will find out last chapter no. by default, so you can download from your beginning point to the last one."
	echo "-l (--location) : location of saved files. Default: current directory, with --subfolder switch on"
	echo "--subfolder : generate subfolder with the name of the targeted webtoon and save files in that folder."
	echo "-p (--pdf) : generate pdf using downloaded images. Required : img2pdf."
	echo "-c (--compress) : generate compressed archive files. Required : 7z (p7zip)"
	echo "output : ./img/(downloaded webtoon.jpg(s)), ./pdf/(generated pdf(s).pdf), ./(comic name).log (wget log), ../(comic name).7z"
	exit;
fi


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--titleID)
    titleid="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--begin)
    begin="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--end)
    end="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--location)
    folder="$2"
    shift # past argument
    shift # past value
    ;;
    --subfolder)
    foldername_autogen=1
    shift
    shift
    ;;
    -p|--pdf)
    pdf=1
    shift
    shift
    ;;
    -c|-compress)
    compress=1
    shift
    shift
    ;;
    *)    # unknown option
    echo "Unknown Option: " "$1" # save it in an array for later
    shift # past argument
    ;;
esac
done

#export titleid="${1}"
#export begin="${2}"
#export end="${3}"
#export folder="${4}"
#export foldername_autogen="${5}"
#export pdf="${6}"
#export compress="${7}"

#retrieve end point
if [[ ${end} == "end" ]]; then
end=$(wget -qO- "https://comic.naver.com/webtoon/list.nhn?titleId=""${titleid}" \
		| grep "/webtoon/detail.nhn?titleId=${titleid}&no=" \
		| head -n 1 | sed 's/<a href="\/webtoon\/detail.nhn?//' \
		| sed 's/titleId.*&no=//' \
		| sed 's/&weekday.*//' \
		| sed 's/^[ \t]*//')
export end
fi

#retrieve the comic title from naver
name=$(wget -qO- 'https://comic.naver.com/webtoon/list.nhn?titleId='"${titleid}" \
	| perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: :: 네이버 만화)?\s*<\/title/si')
export name

#make folder
if [[ ${foldername_autogen} == 1 ]] && [[ -n "${folder}" ]] && [[ "${folder}" != "default" ]]; then
	if [[ ${folder} == */ ]]; then
		mkdir "$folder""$name" 
		cd "$folder""$name" || exit;
	else
		mkdir "$folder"/"$name"
		cd "$folder"/"$name" || exit;
	fi

elif [[ -z "${folder}" ]] || [[ "${folder}" == "default" ]]; then
	mkdir "$name" 
	cd "$name" || exit
else
	mkdir "$folder" 
	cd "$folder" || exit
fi

# download html
echo ====================BEGIN======================
echo start time: "$(date +%c)"
echo location: "$(pwd)"
echo webtoon titleID: "${titleid}"
echo webtoon name: "${name}"
echo pdf: "${pdf}"
echo begin point: "${begin}"
echo end: "${end}"
echo compress: "${compress}"
echo ====================BEGIN======================

#filter comic detail URLs
c=${begin};
while((c<=end));
do echo "https://comic.naver.com/webtoon/detail.nhn?titleId=${titleid}&no=""${c}" >> down.txt;
	((c++));
done;

# make download list using sed & grep
c=${begin};
while read -r p;
do wget --quiet -U mozilla -nv -O temp_"$c" "$p";
	grep "comic content" temp_''"$c"'' | sed "s/<img src=\"//" | sed "s/\".*//" | sed 's/^[ \t]*//' >> ''"$c"'';
	#	grep "comic content" temp_''"$c"'' | sed "s/<img src=\"//" | sed "s/\.gif.*/.gif/" | sed 's/^[ \t]*//' >> ''"$c"'';
	echo "$(date +%c)" link creation: "${c}" out of "${end}"
	((c++));
done<down.txt;
rm down.txt temp*;
echo "$(date +%c)" "create link complete";
#download images
c=${begin};
while((c<=end));
do wget -U "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0" \
	--continue \
	--retry-connrefused \
	--timeout=0.5 \
	--waitretry=0 \
	--tries=30 \
	-a ./"${name}"-download.log \
	-i "${c}";
  for m in ./*IMAG*.jpg ;
  do mv "${m}" "${c}"-"$(echo "${m}" | sed 's/.*_//g' )"
  done
  rm "${c}";
	echo "$(date +%c)" "${c}/${end} downloaded";
	((c++));
done;

# padding 0 for numerical file sorting
# cut no.
c=${begin};
for f in *.jpg;
  do case "$f" in
    *-[0-9].jpg ) echo mv "${f}" "${f//-/-000}";;
    *-[0-9][0-9].jpg ) echo mv "${f}" "${f//-/-00}";;
    *-[0-9][0-9][0-9].jpg ) echo mv "${f}" "${f//-/-0}";;
  esac
done

if [[ ${pdf} == "PDF" ]] || [[ ${pdf} == 1 ]]; then
	if [[ ! -d "pdf" ]]; then
		mkdir ./pdf;
	fi
	while((c<=end));
	do img2pdf "${c}"-*.jpg --output "$c".pdf; 
		echo "PDF: ${c}/${end} complete"
		((c++));
	done
	for f in [0-9].pdf;
	do mv "$f" $(printf %02d%s "${f%.*}" "${a##*.}").pdf;
	done;
	echo "$(date +%c)" "moving pdf"
	mv ./*.pdf ./pdf/
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
mv ./*.jpg ./img;
if [[ ${compress} == 1 ]]; then
	echo compressing using 7z
	7z a "$(pwd)" -o"$(pwd)"/../
fi
echo ====================END====================
echo end time: "$(date +%c)"
echo location: "$(pwd)"
echo webtoon titleID: "${titleid}"
echo webtoon name: "${name}"
echo pdf: "${pdf}"
echo begin point: "${begin}"
echo end: "${end}"
echo compressed: "${compress}"
echo ====================END====================
exit 0
