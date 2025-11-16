import Foundation

/// High-precision performance tracker for measuring activation latency
class PerformanceTracker {
    private static var activationStart: CFAbsoluteTime?
    private static var timings: [(String, CFAbsoluteTime)] = []

    /// Start tracking a new activation cycle
    static func startActivation() {
        activationStart = CFAbsoluteTimeGetCurrent()
        timings.removeAll()
        recordTiming("Hotkey pressed")
    }

    /// Record a timing checkpoint
    static func recordTiming(_ label: String) {
        guard let start = activationStart else { return }
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000 // Convert to ms
        timings.append((label, elapsed))
    }

    /// Finish tracking and log results
    static func finishActivation() {
        guard !timings.isEmpty else { return }

        var report = "\n=== Activation Performance ===\n"
        var previousTime: CFAbsoluteTime = 0

        for (label, elapsed) in timings {
            let delta = elapsed - previousTime
            report += String(format: "%.2fms (+%.2fms) - %@\n", elapsed, delta, label)
            previousTime = elapsed
        }

        if let total = timings.last?.1 {
            report += String(format: "TOTAL: %.2fms\n", total)
        }
        report += "============================\n"

        // Log to file
        let logPath = "/tmp/sniper_perf.log"
        if let data = report.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logPath) {
                if let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: URL(fileURLWithPath: logPath))
            }
        }

        // Also print to console for immediate feedback
        print(report)

        // Reset
        activationStart = nil
        timings.removeAll()
    }
}
