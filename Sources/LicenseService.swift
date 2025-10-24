import Foundation
import Security

class LicenseService {
    private let preferencesStore: PreferencesStore
    private let productID = "YOUR_GUMROAD_PRODUCT_ID" // Replace with actual product ID
    private let gracePeriodDays = 30

    private var cachedLicenseStatus: LicenseStatus?

    init(preferencesStore: PreferencesStore) {
        self.preferencesStore = preferencesStore
        loadCachedLicense()
    }

    var isLicenseValid: Bool {
        guard let status = cachedLicenseStatus else {
            return false
        }

        switch status {
        case .valid, .gracePeriod:
            return true
        case .invalid, .expired, .refunded:
            return false
        }
    }

    func verifyLicenseIfNeeded() async {
        // Check if we need to verify
        guard shouldVerify() else { return }

        // Attempt verification
        guard let licenseKey = getLicenseKey() else {
            cachedLicenseStatus = .invalid
            return
        }

        await verifyLicense(licenseKey: licenseKey)
    }

    func verifyLicense(licenseKey: String, incrementUses: Bool = false) async -> LicenseVerificationResult {
        do {
            let result = try await performGumroadVerification(
                licenseKey: licenseKey,
                incrementUses: incrementUses
            )

            // Store successful license
            if result.success {
                try storeLicenseKey(licenseKey)
                preferencesStore.lastLicenseVerification = Date()
                cachedLicenseStatus = .valid

                if let email = result.purchase?.email {
                    try storeEmail(email)
                }
            } else {
                cachedLicenseStatus = .invalid
            }

            return result

        } catch {
            // If offline and within grace period, allow usage
            if isWithinGracePeriod() {
                cachedLicenseStatus = .gracePeriod
                return LicenseVerificationResult(
                    success: true,
                    purchase: nil,
                    message: "Offline - within grace period"
                )
            }

            cachedLicenseStatus = .invalid
            return LicenseVerificationResult(
                success: false,
                purchase: nil,
                message: error.localizedDescription
            )
        }
    }

    func deactivateLicense() {
        deleteLicenseKey()
        deleteEmail()
        cachedLicenseStatus = .invalid
        preferencesStore.lastLicenseVerification = nil
    }

    // MARK: - Private Methods

    private func shouldVerify() -> Bool {
        guard let lastVerification = preferencesStore.lastLicenseVerification else {
            return true
        }

        // Verify weekly
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return lastVerification < weekAgo
    }

    private func isWithinGracePeriod() -> Bool {
        guard let lastVerification = preferencesStore.lastLicenseVerification else {
            return false
        }

        let gracePeriodEnd = lastVerification.addingTimeInterval(
            TimeInterval(gracePeriodDays * 24 * 60 * 60)
        )
        return Date() < gracePeriodEnd
    }

    private func performGumroadVerification(
        licenseKey: String,
        incrementUses: Bool
    ) async throws -> LicenseVerificationResult {
        let urlString = "https://api.gumroad.com/v2/licenses/verify"
        guard let url = URL(string: urlString) else {
            throw LicenseError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Create device hash for device binding
        let deviceHash = getDeviceHash()

        let parameters = [
            "product_id": productID,
            "license_key": licenseKey,
            "increment_uses_count": incrementUses ? "true" : "false"
        ]

        let bodyString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LicenseError.networkError
        }

        // Parse response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let gumroadResponse = try decoder.decode(GumroadResponse.self, from: data)

        if gumroadResponse.success {
            return LicenseVerificationResult(
                success: true,
                purchase: gumroadResponse.purchase,
                message: "License verified successfully"
            )
        } else {
            return LicenseVerificationResult(
                success: false,
                purchase: nil,
                message: gumroadResponse.message ?? "Verification failed"
            )
        }
    }

    private func loadCachedLicense() {
        guard getLicenseKey() != nil else {
            cachedLicenseStatus = .invalid
            return
        }

        if let lastVerification = preferencesStore.lastLicenseVerification {
            if isWithinGracePeriod() {
                cachedLicenseStatus = .gracePeriod
            } else {
                cachedLicenseStatus = .valid
            }
        } else {
            cachedLicenseStatus = .invalid
        }
    }

    // MARK: - Keychain Operations

    private func storeLicenseKey(_ key: String) throws {
        try storeInKeychain(key: "license_key", value: key)
    }

    private func getLicenseKey() -> String? {
        return getFromKeychain(key: "license_key")
    }

    private func deleteLicenseKey() {
        deleteFromKeychain(key: "license_key")
    }

    private func storeEmail(_ email: String) throws {
        try storeInKeychain(key: "license_email", value: email)
    }

    private func getEmail() -> String? {
        return getFromKeychain(key: "license_email")
    }

    private func deleteEmail() {
        deleteFromKeychain(key: "license_email")
    }

    private func storeInKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw LicenseError.keychainError
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.sniper.license",
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LicenseError.keychainError
        }
    }

    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.sniper.license",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.sniper.license"
        ]

        SecItemDelete(query as CFDictionary)
    }

    private func getDeviceHash() -> String {
        // Create a unique device identifier
        if let uuid = getMachineUUID() {
            return uuid.uuidString
        }
        return UUID().uuidString
    }

    private func getMachineUUID() -> UUID? {
        let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )

        guard platformExpert != 0 else { return nil }

        defer { IOObjectRelease(platformExpert) }

        guard let serialNumberAsCFString = IORegistryEntryCreateCFProperty(
            platformExpert,
            kIOPlatformUUIDKey as CFString,
            kCFAllocatorDefault,
            0
        ) else { return nil }

        if let uuidString = serialNumberAsCFString.takeRetainedValue() as? String {
            return UUID(uuidString: uuidString)
        }

        return nil
    }
}

// MARK: - Models

enum LicenseStatus {
    case valid
    case invalid
    case expired
    case refunded
    case gracePeriod
}

struct LicenseVerificationResult {
    let success: Bool
    let purchase: GumroadPurchase?
    let message: String
}

struct GumroadResponse: Codable {
    let success: Bool
    let purchase: GumroadPurchase?
    let message: String?
}

struct GumroadPurchase: Codable {
    let email: String?
    let productId: String?
    let productName: String?
    let chargebacked: Bool?
    let disputed: Bool?
    let disputeWon: Bool?
    let refunded: Bool?
    let subscriptionEndedAt: String?
    let subscriptionCancelledAt: String?
    let subscriptionFailedAt: String?
}

enum LicenseError: LocalizedError {
    case invalidURL
    case networkError
    case keychainError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid verification URL"
        case .networkError:
            return "Network error during verification"
        case .keychainError:
            return "Failed to store license securely"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
