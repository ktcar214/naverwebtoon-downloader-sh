# naverwebtoon-downloader-sh
bash script to download and convert webtoon contents from naver webtoon.
Original code by nursyah.
Original Repo: https://github.com/nursyah21/webtoon-downloader
Edited by ktcar214.
GNU GPLv3

Requires: img2pdf, bash, sed, grep, wget
Supports: config file(saves progress. Useful for incremental archive with crontab), folder name generation, automatically setup range.
Usage: NaverWebtoonDownloader.sh titleID start end(number or retrieve-see below) folder(path or default-see below) foldername_autogen(1 for true, other value as false) PDF(1, PDF, or omit)
end-number(29, 399, etc): manual range setup. using retrieve will let program automatically detect ending point. 
folder-default: make a folder with comic title and saves file in it. path: manual path setup
foldername_autogen: With path(manual path setup) in folder variable. If it is set as 1, a folder with comic title will be generated and files will be saved in generated folder.
PDF: uses img2pdf. High-quality(No modification to image file), but takes more space than convert(from ImageMagick). Change it if you want.
If it is set as 1 or PDF, pdf files will be generated and saved into pdf folder.
