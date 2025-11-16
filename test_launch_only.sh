#!/bin/bash

echo "Testing App Launch Time (10 iterations)"
echo "========================================="
echo ""

launch_times=()
for i in {1..10}; do
    killall Sniper 2>/dev/null
    sleep 0.5
    rm -f /tmp/sniper_perf.log

    /Applications/Sniper.app/Contents/MacOS/Sniper &
    sleep 1.5

    if [ -f /tmp/sniper_perf.log ]; then
        time_ms=$(grep "App ready in" /tmp/sniper_perf.log | grep -oE '[0-9]+\.[0-9]+')
        if [ ! -z "$time_ms" ]; then
            printf "  Launch %2d: %6.2fms\n" $i $time_ms
            launch_times+=($time_ms)
        fi
    fi
done

echo ""
if [ ${#launch_times[@]} -gt 0 ]; then
    sum=0
    for time in "${launch_times[@]}"; do
        sum=$(echo "$sum + $time" | bc)
    done
    avg=$(echo "scale=2; $sum / ${#launch_times[@]}" | bc)
    echo "Average: ${avg}ms"
else
    echo "No timing data collected"
fi

# Keep app running
echo ""
echo "App is now running. Test hotkey (⌘⇧2) manually."
echo "Check /tmp/sniper_perf.log for timing data."
