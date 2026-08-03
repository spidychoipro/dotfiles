# 3과. 조건문 if

## 배울 것
- `if / elif / else`
- `[ ]` 안의 조건 문법 (공백 필수!)
- 파일/디렉터리 확인, 숫자/문자열 비교

## 이론

**기본 구조** — 파이썬과 구조는 같고, `then`과 `fi`(if 거꾸로)가 등장합니다:
```bash
if [ 조건 ]; then
    ...
elif [ 조건 ]; then
    ...
else
    ...
fi
```

**핵심 주의사항: 대괄호 양옆에 반드시 공백!**
```bash
if [ "$name" = "hoco" ]; then   # OK
if ["$name" = "hoco"]; then     # 오류 (대괄호가 명령어 이름 취급)
```
`[`는 사실 "test"라는 명령어라서, 인자와 인자 사이 공백이 필수입니다.

**자주 쓰는 조건:**
| 조건 | 의미 | 파이썬 |
|------|------|--------|
| `[ -f "$f" ]` | 파일인가? | `os.path.isfile()` |
| `[ -d "$d" ]` | 디렉터리인가? | `os.path.isdir()` |
| `[ -e "$x" ]` | 존재하는가? | `os.path.exists()` |
| `[ "$a" = "$b" ]` | 문자열 같음 | `a == b` |
| `[ "$a" != "$b" ]` | 문자열 다름 | `a != b` |
| `[ "$n" -gt 5 ]` | 숫자 n > 5 | `n > 5` |

숫자 비교 연산자: `-eq`(==) `-ne`(!=) `-gt`(>) `-ge`(>=) `-lt`(<) `-le`(<=)

## 따라하기 (example.sh)
```bash
#!/usr/bin/env bash
target="$1"
if [ -f "$target" ]; then
    echo "'$target' 은(는) 파일입니다."
elif [ -d "$target" ]; then
    echo "'$target' 은(는) 디렉터리입니다."
else
    echo "'$target' 은(는) 없습니다."
fi
```
`./example.sh README.md`, `./example.sh /etc`, `./example.sh 없는것` 세 가지로 실행해보세요.

## 직접 풀어보기 (먼저 풀고, 아래 정답과 비교)
1. 인자로 받은 경로가 **디렉터리면** "폴더입니다", **파일이면** "파일입니다", 없으면 "없음"을 출력하는 스크립트를 만드세요.
2. 숫자 하나를 인자로 받아, 10보다 크면 "크다", 작거나 같으면 "작거나 같다"를 출력하세요.

---

## 정답
```bash
#!/usr/bin/env bash
# 1번
target="$1"
if [ -d "$target" ]; then
    echo "폴더입니다"
elif [ -f "$target" ]; then
    echo "파일입니다"
else
    echo "없음"
fi
```
```bash
#!/usr/bin/env bash
# 2번
n="$1"
if [ "$n" -gt 10 ]; then
    echo "크다"
else
    echo "작거나 같다"
fi
```
