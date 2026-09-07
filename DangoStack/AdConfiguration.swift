//
//  AdConfiguration.swift
//  DangoStack
//

import Foundation

enum AdConfiguration {
    static let interstitialFrequency = 3
    static let interstitialCooldownAfterRewarded: TimeInterval = 90
    static let initialReloadDelay: TimeInterval = 15
    static let maximumReloadDelay: TimeInterval = 60

#if DEBUG
    static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
#else
    static let rewardedAdUnitID = "REWARDED_AD_UNIT_ID_PLACEHOLDER"
    static let interstitialAdUnitID = "INTERSTITIAL_AD_UNIT_ID_PLACEHOLDER"
#endif

    static var isConfigured: Bool {
        isValidAppID(Bundle.main.object(
            forInfoDictionaryKey: "GADApplicationIdentifier"
        ) as? String)
            && isValidAdUnitID(rewardedAdUnitID)
            && isValidAdUnitID(interstitialAdUnitID)
    }

    private static func isValidAppID(_ value: String?) -> Bool {
        guard let value else { return false }
        return value.hasPrefix("ca-app-pub-")
            && value.contains("~")
            && !value.contains("PLACEHOLDER")
    }

    private static func isValidAdUnitID(_ value: String) -> Bool {
        value.hasPrefix("ca-app-pub-")
            && value.contains("/")
            && !value.contains("PLACEHOLDER")
    }
}
