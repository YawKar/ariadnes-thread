#!/bin/bash
# ./01-monitoring-script.sh [-d]

debug_mode=0
while getopts "d" opt; do
  case "$opt" in
    d)
      debug_mode=1
      ;;
    *)
      echo "Usage: $0 [-d]" >&2
      exit 1
      ;;
  esac
done

if [ "$debug_mode" -eq 1 ]; then
  echo "Debug mode is on (set -x)."
  set -x
fi

log_dir="./logs"

mkdir -p "$log_dir"

function cleanup {
  echo "Got shutdown signal."
  exit 0
}

trap 'cleanup' SIGINT SIGTERM

while true; do
  current_date=$(date -I)
  stdout_log="$log_dir/$current_date.stdout.log"
  stderr_log="$log_dir/$current_date.stderr.log"

  find "$log_dir" -regex ".*\.stdout\.log|.*\.stderr\.log" -type f -mtime +3 -exec rm -f {} \;

  if [ ! -f "$stdout_log" ]; then
    echo "==== Monitoring started $(date) ====" >> "$stdout_log"
  fi
  if [ ! -f "$stderr_log" ]; then
    echo "==== Monitoring started $(date) ====" >> "$stderr_log"
  fi

  {
    echo "---- $(date) ----"
    echo "CPU usage:"
    top -bn1 | grep "Cpu(s)" || echo "Error getting CPU statistics."
    echo "Memory usage:"
    free -mh || echo "Error getting memory statistics."
    echo "Disk usage:"
    df -h || echo "Error getting disk statistics."
  } >> "$stdout_log" 2>> "$stderr_log"
  sleep 60
done


