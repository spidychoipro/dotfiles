#!/usr/bin/env bash
# 01 과: 첫 스크립트
# 실행: chmod +x example.sh && ./example.sh

echo "안녕, 셸 스크립트!"

# echo는 파이썬의 print()와 같습니다. 여러 줄도 씁니다.
echo "첫 번째 줄"
echo "두 번째 줄"

# $() 는 명령의 결과를 가져옵니다 (파이썬의 subprocess 정도로만 생각하세요)
echo "지금 시간: $(date +%H:%M)"
