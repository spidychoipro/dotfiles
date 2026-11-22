#!/usr/bin/env bash
# 03 과: 조건문 if
# 실행: ./example.sh 아무파일이름

target="${1:-example.sh}"   # 인자가 없으면 기본값 example.sh

# 파일 존재 여부 확인 (python: os.path.exists() 비슷)
if [ -f "$target" ]; then
    echo "'$target' 은(는) 존재하는 파일입니다."
elif [ -d "$target" ]; then
    echo "'$target' 은(는) 디렉터리입니다."
else
    echo "'$target' 은(는) 없습니다."
fi

# 숫자 비교
num=10
if [ "$num" -gt 5 ]; then
    echo "$num 은(는) 5보다 큽니다."
fi

# 문자열 비교
if [ "$num" = "10" ]; then
    echo "num 은 문자열 '10' 과 같습니다."
fi
