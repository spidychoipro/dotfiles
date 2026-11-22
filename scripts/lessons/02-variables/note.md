# 2과. 변수, 인자, 입력

## 배울 것
- 변수 만들고 쓰기
- 스크립트에 인자 넘기기 (`$1`, `$2`)
- `read`로 입력 받기
- `$( )`로 명령 결과 담기

## 이론

**변수 선언 — 주의: `=` 양옆에 공백이 있으면 안 됩니다.**
```bash
name="hoco"        # OK
name = "hoco"      # 오류! (셸은 'name'이라는 명령을 실행하려 함)
```
파이썬과 달리 자료형이 없고, 전부 문자열로 취급합니다.

**변수 사용 — `$` 를 붙입니다:**
```bash
echo "$name"       # hoco
```
큰따옴표 안에서는 변수가 확장되고, 작은따옴표 안에서는 안 됩니다:
```bash
echo "$name"       # hoco
echo '$name'       # $name (그대로 출력)
```

**인자(argument):** 스크립트 실행 시 넘기는 값
```bash
./script.sh 철수 25
# $1=철수  $2=25
```
파이썬의 `sys.argv[1]`, `sys.argv[2]`와 같습니다.

**입력 받기:**
```bash
echo -n "이름? "    # -n: 줄바꿈 없이 출력
read name          # 입력을 name 변수에 저장 (python input()과 비슷)
```

**명령 결과 담기 — `$( )`:**
```bash
today=$(date +%F)  # date 명령의 출력이 today에 저장됨
echo "$today"
```

## 따라하기 (example.sh)
```bash
#!/usr/bin/env bash
name=$1
age=$2
echo "안녕, $name 님 ($age 살)"
```
`./example.sh 김철수 25` 처럼 인자를 넣어 실행해보세요.
인자 없이 `./example.sh` 만 실행하면 빈 값이 나오는 것도 확인하세요.

## 직접 풀어보기 (먼저 풀고, 아래 정답과 비교)
1. 인자로 받은 이름과 좋아하는 음식을 각각 출력하는 스크립트를 만드세요.
   실행: `./food.sh 홍길동 피자`
2. `read`로 숫자를 하나 입력받고, `$( )`로 "현재 폴더명"을 출력해보세요.
   (폴더명은 `pwd` 명령을 쓰세요)

---

## 정답
```bash
#!/usr/bin/env bash
# 1번
name=$1
food=$2
echo "$name 님은 $food 를 좋아하나요?"
```
```bash
#!/usr/bin/env bash
# 2번
echo -n "숫자를 입력하세요: "
read num
echo "입력한 숫자: $num"
echo "현재 폴더: $(pwd)"
```
