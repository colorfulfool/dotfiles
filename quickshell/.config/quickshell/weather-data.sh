#!/bin/bash
set -u

state="$HOME/.local/state/omarchy/settings/weather.json"
lat=""
lon=""

if [[ -s $state ]]; then
  lat=$(jq -r '(.latitude // empty) | tostring' "$state" 2>/dev/null || true)
  lon=$(jq -r '(.longitude // empty) | tostring' "$state" 2>/dev/null || true)
fi

if [[ -z $lat || -z $lon || $lat == "null" || $lon == "null" ]]; then
  coords=$(curl -fsS --max-time 8 "https://wttr.in/?format=j1" 2>/dev/null | jq -r '.nearest_area[0] | "\(.latitude) \(.longitude)"' 2>/dev/null) || exit 1
  lat=${coords%% *}
  lon=${coords##* }
fi

[[ -n $lat && -n $lon && $lat != "null" && $lon != "null" ]] || exit 1

forecast=$(curl -fsS --max-time 8 "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=apparent_temperature,weather_code,is_day&timezone=auto" 2>/dev/null) || exit 1

aqi=""
iqair=$(curl -fsS --max-time 15 "https://r.jina.ai/https://www.iqair.com/air-quality/kazakhstan/almaty-oblysy/almaty/audit-commission-for-the-city-of-almaty" 2>/dev/null || true)
if [[ -n $iqair ]]; then
  aqi=$(printf '%s\n' "$iqair" | awk '
    { line=$0; gsub(/^[ \t]+|[ \t]+$/, "", line); }
    line ~ /^[0-9]+$/ { last=line }
    /US AQI/ { if (last != "") { print last; exit } }
  ')
fi
[[ $aqi =~ ^[0-9]+$ ]] || aqi=""

if [[ -z $aqi ]]; then
  air=$(curl -fsS --max-time 8 "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${lat}&longitude=${lon}&current=us_aqi&timezone=auto" 2>/dev/null || true)
  [[ -n $air ]] && aqi=$(printf '%s' "$air" | jq -r '.current.us_aqi // empty' 2>/dev/null || true)
fi
[[ $aqi =~ ^[0-9]+$ ]] || aqi=null

jq -cn --argjson f "$forecast" --argjson aqi "$aqi" \
  '{apparent: ($f.current.apparent_temperature // null), aqi: $aqi, weather: ($f.current.weather_code // null), day: ($f.current.is_day // null)}'
