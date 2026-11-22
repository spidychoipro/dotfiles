# 5과. 함수 + 실전(파일 정리)

## 배울 것
- 함수 정의와 호출
- 지금까지 배운 것(조건, 반복, 인자)을 하나의 실용 스크립트로 조합

## 이론

**함수 정의** — 파이썬의 `def`와 같습니다:
```bash
안녕() {
    echo "안녕하세요"
}
안녕            # 호출 (파이썬처럼 괄호 없이 이름만)
```

**인자 받기 — `$1`, `$2` (스크립트 인자와 같은 규칙):**
```bash
인사() {
    echo "안녕, $1 님"     # 함수의 첫 번째 인자
}
인사 철수        # -> 안녕, 철수 님
```

**`local` — 함수 안에서만 쓰는 변수:**
```bash
myfunc() {
    local x="$1"     # 이 함수 안에서만 존재하는 변수
}
```
안 쓰면 함수 밖 변수를 덮어쓸 수 있습니다.

**`case` — 여러 조건 분기 (python의 `match` 또는 if/elif/else):**
```bash
case "$1" in
    png|jpg) echo "이미지" ;;
    txt)     echo "문서" ;;
    *)       echo "기타" ;;
esac
```

**`basename` / `${base##*.}`:**
- `basename /경로/파일.txt` → `파일.txt` (경로 제거)
- `${base##*.}` → `txt` (마지막 점 뒤 확장자)

## 따라하기 (example.sh)
`./example.sh` 는 **안전 모드**로, 실제로 이동하지 않고 "이동 예정"만 보여줍니다.
```bash
mkdir -p test_downloads
touch test_downloads/사진.jpg test_downloads/문서.pdf test_downloads/압축.zip
./example.sh test_downloads            # 예상 결과만 표시
./example.sh test_downloads --apply    # 실제 이동
ls test_downloads/images test_downloads/documents test_downloads/archives
```
안전 모드(먼저 보여주고, `--apply`일 때만 실행)는 **실제로 지우는/옮기는 스크립트의 좋은 습관**입니다.

## 직접 풀어보기 (먼저 풀고, 아래 정답과 비교)
1. 인자를 받아 "안녕, [이름]"을 출력하는 `greet` 함수를 만들고 호출하세요.
2. 폴더를 통째로 복사하는 백업 스크립트를 만드세요.
   - 인자: 원본 폴더
   - `cp -r 원본 원본_백업_날짜` 로 복사
   - 날짜는 `$(date +%Y%m%d)` 사용 (예: 20260803)

---

## 정답
```bash
#!/usr/bin/env bash
# 1번
greet() {
    echo "안녕, $1"
}
greet "홍길동"
```
```bash
#!/usr/bin/env bash
# 2번
src="$1"
if [ ! -d "$src" ]; then
    echo "폴더가 없습니다: $src"
    exit 1
fi
dst="${src}_백업_$(date +%Y%m%d)"
cp -r "$src" "$dst"
echo "백업 완료: $dst"
```
