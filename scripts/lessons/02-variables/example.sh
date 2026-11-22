#!/usr/bin/env bash
# 02 과: 변수, 인자, 입력
# 실행: ./example.sh 김철수 25

# 변수 선언: '=' 앞뒤에 공백이 있으면 안 됩니다!
name=$1          # 첫 번째 인자 (파이썬의 sys.argv[1])
age=$2           # 두 번째 인자 (sys.argv[2])

# 변수 사용: "$변수" 형태 (큰따옴표 안에서도 확장됨)
echo "안녕, $name 님 ($age 살)"

# read: 사용자 입력 받기 (파이썬의 input() 과 비슷)
echo -n "질문: 오늘 뭐 배울까요? "
read answer
echo "좋아요, $answer 배워봅시다!"

# $() 명령 치환: 명령 결과를 변수에 저장
today=$(date +%F)
echo "오늘 날짜: $today"
