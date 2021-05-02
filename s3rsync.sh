#!/bin/bash

LOG_ENABLE=false
BUCKET_NAME="hogehoge"

function current_datetime(){
  echo `date "+%Y-%m-%d  %H:%M:%S"`
}


function error_messages(){
  echo -n "ERROR! ["
  echo -n "$1"
  echo "]"
}

function echo_separator() {
  if "${LOG_ENABLE}" ; then
    echo -n `current_datetime` " " >> log.txt
    echo "-------------------------------------------" >> log.txt
  else
    echo "-------------------------------------------"
  fi
}

function logger() {
  if "${LOG_ENABLE}" ; then
    echo -n `current_datetime` " " >> log.txt
    echo $1 >> log.txt
  else
    echo ${1}
  fi
}

if [ $# -lt 3 ]; then
  error_messages "引数は3つ指定してください"
  exit 1
fi

if [ $2 -eq 0 ]; then
  error_messages "グループは0以上で指定してください"
  exit 1
fi

if [ $1 != "disc1" ] && [ $1 != "disc2_1" ] && [ $1 != "disc2_2" ] && [ $1 != "disc3" ] && [ $1 != "disc4" ]; then
  error_messages "不正なdiscが指定されました"
  exit 1
fi

if [ -n $4 ]; then
  LOG_ENABLE=true
fi

disc=$1
group=$2
split=$3

if [ $1 == "disc1" ]; then
  DISC_PATH="/mnt/nfs/contents-01/${disc}"
elif [ $1 == "disc2_1" ] || [ $1 == "disc2_2" ]; then
  DISC_PATH="/mnt/nfs/contents-02/${disc}"
elif [ $1 == "disc3" ]; then
  DISC_PATH="/mnt/nfs/contents-03/${disc}"
elif [ $1 == "disc4" ]; then
  DISC_PATH="/mnt/nfs/contents-04/${disc}"
fi

MOVIE_PATH="${DISC_PATH}/movie"
#MOVIE_PATH="/Users/yoshi/work"

echo $MOVIE_PATH

array=($(ls "${MOVIE_PATH}"))

i=1
n=1

echo_separator
logger "選択されたディスク:${1}"
logger "コピーグループ:${2}"
logger "分割数:${3}"
echo_separator

for eachValue in ${array[@]}; do
    if [ $i -eq $group ]; then
        logger "コピー対象:${eachValue}"
    fi
    if [ $i -eq $split ];then
        i=0
    fi
    let i++
    let n++
done

i=1
n=1
for dir in ${array[@]}; do
    if [ $i -eq $group ]; then
        echo_separator
	logger "コピー元ディレクトリ：${MOVIE_PATH}/${dir}"
	logger "コピー先ディレクトリ：s3://${BUCKET_NAME}/${disc}/movie/${dir}"
        aws s3 sync ${MOVIE_PATH}/${dir} s3://${BUCKET_NAME}/${disc}/movie/${dir} --delete --exact-timestamps >> debug_log.txt 2>> error.log
	logger "ディレクトリコピー完了"
    fi
    if [ $i -eq $split ];then
        i=0
    fi
    let i++
    let n++
done
echo_separator
