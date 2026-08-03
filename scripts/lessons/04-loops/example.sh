#!/usr/bin/env bash
# 04 과: 반복문 for / while
# 실행: ./example.sh

# for: 파일 목록 돌기 (python: for f in os.listdir():)
echo "== 현재 폴더의 .sh 파일들 =="
for f in *.sh; do
    if [ -f "$f" ]; then
        echo "  $f"
    fi
done

# for: 숫자 돌기 (python: for i in range(1, 6):)
echo "== 1부터 5까지 =="
for i in 1 2 3 4 5; do
    echo "  $i"
done

# while + 산술: (python: while i < 3: i += 1)
echo "== while 카운터 =="
i=0
while [ "$i" -lt 3 ]; do
    echo "  i=$i"
    i=$((i + 1))
done

# `$(seq 1 5)` 로도 같은 범위를 만들 수 있습니다
echo "== seq 사용 =="
for n in $(seq 1 3); do
    echo "  n=$n"
done
