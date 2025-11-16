#!/bin/bash

echo "Sniper Performance Test"
echo "======================="
echo ""

# Test 1: Launch time
echo "Test 1: App Launch Time"
echo "-----------------------"
echo "Running 10 launches..."
echo ""

total_time=0
for i in {1..10}; do
    # Kill if running
    killall Sniper 2>/dev/null
    sleep 0.5

    # Time the launch
    start=$(gdate +%s.%N)
    open /Applications/Sniper.app

    # Wait for app to be running
    while ! pgrep -x "Sniper" > /dev/null; do
        sleep 0.01
    done

    end=$(gdate +%s.%N)
    elapsed=$(echo "$end - $start" | bc)

    echo "Launch $i: ${elapsed}s"
    total_time=$(echo "$total_time + $elapsed" | bc)

    sleep 1
done

avg_time=$(echo "scale=3; $total_time / 10" | bc)
echo ""
echo "Average launch time: ${avg_time}s"
echo ""

echo "Test 2: Hotkey Response Time"
echo "-----------------------------"
echo "This requires manual testing:"
echo "1. Press ⌘⇧2 and observe how quickly the overlay appears"
echo "2. Look at the console logs for timing information"
echo ""
echo "Check /tmp/sniper.log for detailed timing"
