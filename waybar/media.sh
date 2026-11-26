#!/usr/bin/env bash
# Single source of truth for the media target.
# Used by the waybar widget, its click/scroll actions and the keyboard binds.
set -u

action=${1:-metadata}

select_player() {
	local default_name target="" fallback="" seen_default=0 n s a t p dl tl

	default_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null) || default_name=""
	dl=${default_name,,}

	# -a metadata lists players that actually have a track (Stopped ones are skipped).
	while IFS='|' read -r n s a t; do
		[ -z "$n" ] && continue
		[ "${n,,}" = "$dl" ] && seen_default=1
		if [ "$s" = "Playing" ]; then
			if [ "${n,,}" = "$dl" ]; then
				target="$n"
			else
				target=${target:-$n}
			fi
		else
			fallback=${fallback:-$n}
		fi
	done < <(playerctl -a metadata --format '{{playerName}}|{{status}}|{{artist}}|{{title}}' 2>/dev/null)

	[ -z "$target" ] && [ "$seen_default" -eq 1 ] && target="$default_name"
	[ -z "$target" ] && target="$fallback"
	[ -z "$target" ] && return 0

	# playerctl -l uses instance-qualified names (e.g. brave.instance1670),
	# while {{playerName}} reports the bare name (brave). Map back to the exact name.
	tl=${target,,}
	while IFS= read -r p; do
		case "${p,,}" in
			"$tl"|"$tl".*)
				printf '%s\n' "$p"
				return 0
				;;
		esac
	done < <(playerctl -l 2>/dev/null)
	printf '%s\n' "$target"
}

player=$(select_player)
[ -z "$player" ] && exit 0

case "$action" in
	metadata)
		playerctl --player="$player" metadata \
			--format '{{playerName}}|{{status}}|{{artist}}|{{title}}' 2>/dev/null || true
		;;
	play-pause|next|prev)
		if command -v swayosd-client >/dev/null 2>&1; then
			act=$action
			[ "$act" = "prev" ] && act="previous"
			swayosd-client --playerctl "$act" --player "$player" >/dev/null 2>&1 || true
		else
			act=$action
			[ "$act" = "prev" ] && act="previous"
			playerctl --player="$player" "$act" >/dev/null 2>&1 || true
		fi
		;;
esac
