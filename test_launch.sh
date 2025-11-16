#!/bin/bash

echo "Testing Sniper Launch Performance"
echo "=================================="
echo ""

# Clear existing logs
> /tmp/sniper_launch_times.txt

for i in {1..10}; do
    echo "Test $i/10..."

    # Kill if running
    killall Sniper 2>/dev/null
    sleep 0.5

    # Launch and capture output
    /Applications/Sniper.app/Contents/MacOS/Sniper > /tmp/sniper_test_$i.log 2>&1 &

    # Wait for app to be running
    sleep 2

    # Extract timing from log
    if [ -f /tmp/sniper_test_$i.log ]; then
        grep "App ready in" /tmp/sniper_test_$i.log | tail -1 >> /tmp/sniper_launch_times.txt
    fi
done

echo ""
echo "Results:"
echo "--------"
cat /tmp/sniper_launch_times.txt

# Calculate average
if command -v bc &> /dev/null; then
    avg=$(grep -oE '[0-9]+\.[0-9]+' /tmp/sniper_launch_times.txt | awk '{s+=$1} END {print s/NR}')
    echo ""
    echo "Average: ${avg}ms"
fi

echo ""
echo "Testing hotkey response time..."
echo "Press ⌘⇧2 a few times and watch the console output"
echo "Look for the time between 'Hotkey pressed' and 'Overlay ready'"
