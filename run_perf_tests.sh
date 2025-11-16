#!/bin/bash

echo "================================================"
echo "  Sniper Performance Tests"
echo "================================================"
echo ""

# Test 1: Launch Time
echo "Test 1: App Launch Time (10 iterations)"
echo "----------------------------------------"
echo ""

launch_times=()
for i in {1..10}; do
    killall Sniper 2>/dev/null
    sleep 0.5
    rm -f /tmp/sniper_perf.log

    /Applications/Sniper.app/Contents/MacOS/Sniper &
    sleep 1

    if [ -f /tmp/sniper_perf.log ]; then
        time_ms=$(grep "App ready in" /tmp/sniper_perf.log | grep -oE '[0-9]+\.[0-9]+')
        echo "  Launch $i: ${time_ms}ms"
        launch_times+=($time_ms)
    fi
done

# Calculate average
if [ ${#launch_times[@]} -gt 0 ]; then
    sum=0
    for time in "${launch_times[@]}"; do
        sum=$(echo "$sum + $time" | bc)
    done
    avg=$(echo "scale=2; $sum / ${#launch_times[@]}" | bc)
    echo ""
    echo "  Average Launch Time: ${avg}ms"
fi

echo ""
echo ""

# Test 2: Hotkey Response Time
echo "Test 2: Hotkey Response Time"
echo "-----------------------------"
echo ""
echo "Instructions:"
echo "1. Make sure Sniper is running"
echo "2. Press ⌘⇧2 several times (try 5-10 times)"
echo "3. Each time, wait for the overlay to appear before pressing Escape"
echo "4. Then press Enter here to see the results"
echo ""
read -p "Press Enter when you've finished testing the hotkey..."

echo ""
echo "Analyzing hotkey response times..."
echo ""

# Extract timing data from log
grep -A1 "Hotkey pressed" /tmp/sniper_perf.log | while read line; do
    if [[ $line == *"Hotkey pressed"* ]]; then
        hotkey_time=$(echo $line | grep -oE '[0-9]+\.[0-9]+')
    elif [[ $line == *"Overlay ready"* ]]; then
        ready_time=$(echo $line | grep -oE '[0-9]+\.[0-9]+')
        if [ ! -z "$hotkey_time" ] && [ ! -z "$ready_time" ]; then
            diff=$(echo "scale=2; ($ready_time - $hotkey_time) * 1000" | bc)
            echo "  Hotkey → Overlay ready: ${diff}ms"
        fi
    fi
done

echo ""
echo "Done!"
