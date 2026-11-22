# Thunar 다크모드 통합 수정

Hyprland + GTK3 환경에서 Thunar 파일 관리자가 망가지는 문제를 한 방에 고치는 스크립트.

## 증상 → 원인 → 해결

| 증상 | 원인 | 해결 |
|---|---|---|
| 폴더/파일 **이름이 안 보임** (클릭하면 보임) | dconf `gtk-theme`이 미설치 테마(`adw-gtk3-dark`)를 가리킴 → GTK가 라이트 기본값으로 폴백 → 검정 텍스트가 커스텀 CSS의 어두운 배경 위에 렌더링 | ② |
| 주소창(path bar)만 **라이트모드** | 동일 — 테마 폴백으로 path-bar 버튼이 라이트 스타일 유지 | ② |
| 사이드바(Places) 항목 **누락·깨짐**, 휴지통/장치 없음 | `gvfs` 미설치 — GIO 볼륨 모니터 없이 사이드바 목록이 불완전하게 채워짐 | ① |
| 화면 요소가 **아예 안 보이거나 절반만** 렌더링 | 로컬 `~/.config/gtk-3.0/thunar.css`가 `opacity: 0` + CSS fade-in 애니메이션 사용 — GTK3에서 애니메이션이 실행 실패하면 그 상태로 고착 | ③ |
| 아이콘 깨짐/누락 | dconf `icon-theme`이 미설치 테마(`Papirus-Dark`) 가리킴 | ④ |

핵심 교훈: **GTK는 `~/.config/gtk-3.0/settings.ini`보다 dconf(GSettings) 값을 우선한다.**
settings.ini에 다크 테마를 적어둬도 dconf에 없는 테마 이름이 있으면 무시되고 라이트 모드로 렌더링된다.

## 설치 (한방)

```bash
bash ~/dotfiles/thunar-fix/install.sh
```

**진단 기반 동작**: 5개 항목(gvfs / dconf gtk-theme / dconf icon-theme / gtk-3.0 css / gtk-4.0 css)을
각각 검사해서 **문제가 발견된 것만** 수정한다. 전부 정상이면 아무것도 건드리지 않음.
테마 대상은 `~/.config/gtk-3.0/settings.ini` 선언값을 우선 참고하고, 미설치면 설치된 폴백 후보 사용.

다른 모드:

```bash
bash ~/dotfiles/thunar-fix/install.sh --check    # 진단만 (수정 없음, 문제 있으면 exit 1)
bash ~/dotfiles/thunar-fix/install.sh --dry-run  # 적용될 명령 미리보기
```

gvfs 설치 시 sudo 비밀번호를 묻고, 나머지는 자동 적용.
실행 중인 Thunar는 재시작 필요: `pkill -x Thunar`

## 적용 내역

1. `pacman -S gvfs` — 휴지통, 마운트/장치, 네트워크 장소 활성화
2. `gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'`
   `gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark'`
3. `~/.config/gtk-{3,4}.0/gtk.css`에서 `@import "thunar.css"` 주석 처리
   (수정 전 원본은 같은 폴더에 `.bak.<타임스탬프>`로 백업)
4. 정의되지 않은 `@primary` 색 참조(`theme_selected_fg_color`)를 `#f8f8f2`로 수정
   — GTK CSS 파서 에러 유발 요소 제거

## 되돌리기

```bash
# css 백업 복원
cp ~/.config/gtk-3.0/gtk.css.bak.<타임스탬프> ~/.config/gtk-3.0/gtk.css

# 테마 원복 (예시)
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
```

단, thunar.css는 GTK4(GTK4는 CSS 애니메이션 지원)용으로 재작성하기 전까지는
다시 켜도 같은 문제가 재발하므로 비활성 상태 유지 권장.

## 참고

- Dracula GTK 테마 미설치 시: <https://github.com/dracula/gtk>
- 이 패키지는 [spidychoipro/dotfiles](https://github.com/spidychoipro/dotfiles)에서 관리됨
