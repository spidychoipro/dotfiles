# 4과. 반복문 for / while

## 배울 것
- `for ... in ...; do ... done`
- `while [ 조건 ]; do ... done`
- 산술 연산 `$(( ))`

## 이론

**for — 목록을 돌 때** (파이썬 `for x in 목록:` 과 같음):
```bash
for f in *.txt; do        # *.txt 는 그 폴더의 txt 파일들 (glob)
    echo "파일: $f"
done
```
- `*.txt` 같은 **glob**은 터미널이 "지금 여기 있는 txt 파일들"로 바꿔줍니다.
- 순서대로 돌고 끝나면 `done`에서 끝납니다.

**for — 숫자를 돌 때:**
```bash
for i in 1 2 3 4 5; do ... done
for n in $(seq 1 5); do ... done    # seq로 1~5 생성
```
(파이썬의 `range(1,6)`에 가까운 건 `$(seq 1 5)`)

**while — 조건이 참인 동안:**
```bash
i=0
while [ "$i" -lt 3 ]; do
    echo "$i"
    i=$((i + 1))     # 산술: $(( )) 안에서 계산
done
```
- `$(( ))` 는 셸의 산술 연산자입니다. `$((i + 1))` = 파이썬 `i += 1` 정도.

## 따라하기 (example.sh)
`./example.sh` 를 실행하고, 각 루프가 어떻게 도는지 확인해보세요.
그 폴더에 `.sh` 파일을 추가한 뒤 다시 실행하면 목록이 달라지는 것도 확인!

## 직접 풀어보기 (먼저 풀고, 아래 정답과 비교)
1. 현재 폴더의 **모든 파일**(`*`)에 대해, `파일명`을 한 줄씩 출력하는 스크립트를 만드세요.
   (출력은 `echo "파일: $f"` 형식)
2. `for`를 써서 1부터 10까지 **짝수만** 출력해보세요. 힌트: `$((i % 2))` 가 0이면 짝수, 그리고 3과의 `if`를 조합.

---

## 정답
```bash
#!/usr/bin/env bash
# 1번
for f in *; do
    echo "파일: $f"
done
```
```bash
#!/usr/bin/env bash
# 2번
for i in $(seq 1 10); do
    if [ $((i % 2)) -eq 0 ]; then
        echo "$i"
    fi
done
```
