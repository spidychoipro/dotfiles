#!/usr/bin/env bash
# 05 과: 함수 + 실전 (파일 정리 스크립트)
# 실행: ./example.sh   (안전 모드: 이동을 하지 않고 "하면 될 일"만 보여줌)
# 실제 이동을 하려면 --apply 옵션을 붙이세요: ./example.sh --apply

# 대상 폴더 (기본: 이 스크립트가 있는 폴더 아래 test_downloads)
target_dir="${1:-test_downloads}"

# --- 함수 정의 (파이썬의 def 와 같음) ---
# 확장자 -> 폴더 이름 매칭
categorize() {
    local ext="$1"
    case "$ext" in
        jpg|jpeg|png|gif)  echo "images" ;;
        pdf|docx|txt)      echo "documents" ;;
        zip|tar|gz)        echo "archives" ;;
        *)                 echo "others" ;;
    esac
}

organize() {
    local apply="$1"
    for file in "$target_dir"/*; do
        [ -f "$file" ] || continue          # 파일만, 폴더는 건너뜀

        local base ext cat
        base=$(basename "$file")
        ext="${base##*.}"                    # 확장자 추출 (마지막 점 뒤)
        cat=$(categorize "$ext")             # 함수 호출

        if [ "$apply" = "--apply" ]; then
            mkdir -p "$target_dir/$cat"
            mv "$file" "$target_dir/$cat/"
            echo "이동: $base -> $cat/"
        else
            echo "이동 예정: $base -> $cat/"
        fi
    done
}

# --- 메인 ---
echo "== 파일 정리 스크립트 (대상: $target_dir/) =="
organize "$2"
