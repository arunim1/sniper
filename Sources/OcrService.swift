import Vision
import CoreImage
import AppKit

class OcrService {
    private let preferencesStore: PreferencesStore

    init(preferencesStore: PreferencesStore) {
        self.preferencesStore = preferencesStore
    }

    func recognizeText(in image: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OcrError.noTextFound)
                    return
                }

                let recognizedText = self.processObservations(observations)
                continuation.resume(returning: recognizedText)
            }

            // Configure recognition level
            if preferencesStore.recognitionLevel == "fast" {
                request.recognitionLevel = .fast
            } else {
                request.recognitionLevel = .accurate
            }

            // Configure languages
            request.recognitionLanguages = preferencesStore.ocrLanguages
            request.usesLanguageCorrection = true

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func processObservations(_ observations: [VNRecognizedTextObservation]) -> String {
        var lines: [(text: String, bounds: CGRect, confidence: Float)] = []

        // Extract text from observations
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }

            lines.append((
                text: candidate.string,
                bounds: observation.boundingBox,
                confidence: candidate.confidence
            ))
        }

        // Sort by vertical position (top to bottom)
        lines.sort { $0.bounds.minY > $1.bounds.minY }

        // Group into lines based on Y proximity
        var groupedLines: [[String]] = []
        var currentLineGroup: [String] = []
        var lastY: CGFloat?
        let lineThreshold: CGFloat = 0.02 // 2% of image height

        for line in lines {
            let currentY = line.bounds.midY

            if let lastY = lastY, abs(currentY - lastY) < lineThreshold {
                // Same line - add to current group
                currentLineGroup.append(line.text)
            } else {
                // New line
                if !currentLineGroup.isEmpty {
                    groupedLines.append(currentLineGroup)
                }
                currentLineGroup = [line.text]
            }

            lastY = currentY
        }

        // Don't forget the last group
        if !currentLineGroup.isEmpty {
            groupedLines.append(currentLineGroup)
        }

        // Sort words within each line by X position (left to right)
        for i in 0..<groupedLines.count {
            let lineIndices = groupedLines[i].indices
            let sortedWords = lineIndices.sorted { idx1, idx2 in
                let bounds1 = lines.first { $0.text == groupedLines[i][idx1] }?.bounds ?? .zero
                let bounds2 = lines.first { $0.text == groupedLines[i][idx2] }?.bounds ?? .zero
                return bounds1.minX < bounds2.minX
            }
            groupedLines[i] = sortedWords.map { groupedLines[i][$0] }
        }

        // Join words and lines
        var result = groupedLines.map { $0.joined(separator: " ") }

        // Post-process
        result = result.map { processLine($0) }

        // Join lines
        if preferencesStore.preserveLineBreaks {
            return result.joined(separator: "\n")
        } else {
            return result.joined(separator: " ")
        }
    }

    private func processLine(_ line: String) -> String {
        var processed = line

        // Trim whitespace
        processed = processed.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove soft hyphens at line breaks
        processed = processed.replacingOccurrences(of: "-\n", with: "")
        processed = processed.replacingOccurrences(of: "­\n", with: "") // soft hyphen

        // Normalize whitespace
        processed = processed.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )

        // Smart URL/email protection - ensure no spaces in common patterns
        let urlPattern = "(https?://[^\\s]+)"
        processed = processed.replacingOccurrences(
            of: urlPattern + "\\s+",
            with: "$1",
            options: .regularExpression
        )

        let emailPattern = "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})"
        processed = processed.replacingOccurrences(
            of: emailPattern + "\\s+",
            with: "$1",
            options: .regularExpression
        )

        return processed
    }
}

enum OcrError: LocalizedError {
    case noTextFound
    case lowConfidence

    var errorDescription: String? {
        switch self {
        case .noTextFound:
            return "No text was detected in the selected region"
        case .lowConfidence:
            return "The recognized text may be inaccurate"
        }
    }
}
