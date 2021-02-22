#! /bin/bash
## Code refactored by ktcar214. 2020.08.04~
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
	echo "--pdf-aio: generate pdf, but in one file. All comic images will be included, without being divided into chapter."
	echo "-c (--compress) : generate compressed archive files. Required : 7z (p7zip)"
	echo "--force-pc: Use images from PC version regardelss of comic format."
	echo "Exit status: 0(success), 99(Unknown Variable)"
	echo "Example: ./Naverwebtoondownloader.sh -t 000000"
	exit 0;
fi

#set variables with default
export begin=1
export end="end"
export pdf=0
export compress=0
export pdf_aio=0
export cut=0

# set variables from arguments
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-t|--titleid)
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
	--pdf-aio)
		pdf=1
		pdf_aio=1
		shift
		shift
		;;
	-c|-compress)
		compress=1
		shift
		shift
		;;
  --force-pc)
    force_pc=1
    shift
    shift
    ;;
	*)    # unknown option
		echo "Unknown Option: " "$1" # save it in an array for later
		exit 99
		;;
esac
done

#retrieve webtoon info
echo verifying titleId and other parameters...
wget -q -O./."${titleid}"_naverwebtoondownloadersh-temp.html \
"https://comic.naver.com/webtoon/list.nhn?titleId=""${titleid}"


#retrieve end point
if [[ ${end} == "end" ]] || [[ -z ${end} ]]; then
end=$(grep "/webtoon/detail.nhn?titleId=${titleid}&no="  ."${titleid}"_naverwebtoondownloadersh-temp.html \
	| head -n 1 | sed 's/<a href="\/webtoon\/detail.nhn?//' \
	| sed 's/titleId.*&no=//' \
	| sed 's/&weekday.*//' \
	| sed 's/^[ \t]*//')
	export end
fi

if grep -q ico_cut ."${titleid}"_naverwebtoondownloadersh-temp.html
then
	if [[ ${force_pc} != 1 ]]; then
	cut=1
	export cut
  fi
fi
#retrieve the comic title from naver
name=$(grep "<title>" ."${titleid}"_naverwebtoondownloadersh-temp.html | sed -e "s/.*<title>\(.*\)\ ::.*/\1/g")
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
echo PDF all in one file: "${pdf_aio}"
echo begin point: "${begin}"
echo end: "${end}"
echo compress: "${compress}"
echo cut toon: "${cut}"
echo ====================BEGIN======================

#filter comic detail URLs
c=${begin};
if [[ $cut == 0 ]]; then
	while((c<=end));
	# make download list using sed & grep
do wget --quiet -U mozilla -nv \
-O-"https://comic.naver.com/webtoon/detail.nhn?titleId=${titleid}&no=""${c}"| \
		grep "comic content" temp_"$c" | grep -Eo "https.*.jpg" >> .image_dl_"$c".list;
		#	grep "comic content" temp_''"$c"'' | sed "s/<img src=\"//" | sed "s/\.gif.*/.gif/" | sed 's/^[ \t]*//' >> ''"$c"'';
		echo "$(date +%c)" link creation: "${c}" out of "${end}"
  ((c++));
	done
	echo "$(date +%c)" "link creation complete";
else
	while((c<=end));
	do wget --quiet -U mozilla -nv \
	-O- "https://m.comic.naver.com/webtoon/detail.nhn?titleId=${titleid}&no=""${c}"| \
		grep mobilewebimg temp_"$c" | grep -Eo "https.*.jpg" >> .image_dl_"$c".list
		echo "$(date +%c)" link creation: "${c}" out of "${end}"
		((c++));
	done;
	echo "$(date +%c)" "create link complete";
fi

#download images
if [[ ! -d "img" ]]; then
	mkdir ./img;
fi
cd img || exit
c=${begin};
while((c<=end));
do wget -U "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0" \
	--continue \
	--retry-connrefused \
	--timeout=0.5 \
	--waitretry=0 \
	--tries=30 \
	-a ./"${name}"-download.log \
	-i ../.image_dl_"${c}".list;
	if [[ ${cut} == 0 ]]; then
		for m in ./*IMAG*.jpg ;
		do mv "${m}" "${c}"-"${m//*_/}"
		done
	else
		for m in *_*.jpg ;
		do mv "${m}" "${c}"-"${m//*_/}"
		done
	fi
	rm "${c}";
	echo "$(date +%c)" "${c}/${end} downloaded";
	((c++));
done;

# padding 0 for numerical file sorting
# cut no.
for f in *.jpg;
do case "$f" in
	*-[0-9].jpg ) mv "${f}" "${f//-/-000}";;
	*-[0-9][0-9].jpg ) mv "${f}" "${f//-/-00}";;
	*-[0-9][0-9][0-9].jpg ) mv "${f}" "${f//-/-0}";;
esac
done

if [[ ${pdf} == 1 ]] && [[ ${pdf_aio} != 1 ]]; then
	if [[ ! -d "pdf" ]]; then
		mkdir ../pdf;
	fi
	c=${begin};
	while((c<=end));
	do img2pdf "${c}"-*.jpg --output ../pdf/"$c".pdf;
		echo "PDF: ${c}/${end} complete"
		((c++));
	done
	for f in [0-9].pdf;
	do mv "$f" $(printf %02d%s "${f%.*}" "${a##*.}").pdf;
	done;
fi
# clean up
for f in ./*.jpg;
do case $f in
	[0-9]-*.jpg ) mv "${f}" "$(echo 000"${f}")";;
	[0-9][0-9]-*.jpg ) mv "${f}" "$(echo 00"${f}")";;
	[0-9][0-9][0-9]-*.jpg ) mv "${f}" "$(echo 0"${f}")";;
esac
done

if [[ ${pdf_aio} == 1 ]]; then
	echo "generating PDF (All in One file)"
	img2pdf ./*.jpg --output ../pdf/"${name}".pdf
fi

mv ./*.jpg ./img;
if [[ ${compress} == 1 ]]; then
	echo compressing using 7z
	7z a "$(pwd)"/../ -o"$(pwd)"/../../
fi
echo ====================END====================
echo end time: "$(date +%c)"
echo location: "$(pwd)"
echo webtoon titleID: "${titleid}"
echo webtoon name: "${name}"
echo pdf: "${pdf}"
echo PDF all in one file: "${pdf_aio}"
echo begin point: "${begin}"
echo end: "${end}"
echo compressed: "${compress}"
echo ====================END====================
exit 0
