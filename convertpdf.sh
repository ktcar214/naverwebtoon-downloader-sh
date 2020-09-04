#!/bin/bash
c=1;
rm -r "${1}"/pdf/ && mkdir "${1}"/pdf/
cd "${1}"/img/
end=$( ls -vr | head -n 1 | sed 's/-.*//' | sed 's/^0*//')
#echo $end
#exit
while((${c}<=${end}));
do case ${c} in
	[0-9] ) t="$(echo "${c}" | sed 's/^/000/')";;
	[0-9][0-9] ) t="$(echo "${c}" | sed 's/^/00/')";;
	[0-9][0-9][0-9] ) t="$(echo "${c}" | sed 's/^/0/')";;
esac
	img2pdf "${t}"-*.jpg --output "${t}".pdf;
	echo "PDF: ${c}/${end} complete";
	((c++));
done
#for f in [0-9]-*.jpg;
#do mv "${f}" "$(echo "${f}" | sed 's/^/000/')";
#done;
#for f in [0-9][0-9]-*.jpg;
#do mv "${f}" "$(echo "${f}" | sed 's/^/00/')";
#done;
#for f in [0-9][0-9][0-9]-*.jpg;
#do mv "${f}" "$(echo "${f}" | sed 's/^/0/')";
#done;
#for f in [0-9].pdf;
#do mv "$f" $(printf %03d%s "${f%.*}" "${a##*.}").pdf;
#done;
#for f in [0-9][0-9].pdf;
#do mv "$f" $(printf %02d%s "${f%.*}" "${a##*.}").pdf;
#done;
#for f in [0-9][0-9][0-9].pdf;
#do mv "$f" $(printf %01d%s "${f%.*}" "${a##*.}").pdf;
#done;
mv *.pdf ../pdf/
echo "complete:""${1}"
#fi
