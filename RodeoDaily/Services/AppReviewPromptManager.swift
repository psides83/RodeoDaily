import Foundation
import StoreKit
import UIKit

@MainActor
final class AppReviewPromptManager {
    static let shared = AppReviewPromptManager()

    private enum Keys {
        static let activeSessionCount = "review_prompt_active_session_count"
        static let promptCount = "review_prompt_count"
        static let lastPromptDate = "review_prompt_last_prompt_date"
        static let hasRated = "review_prompt_has_rated"
    }

    private let defaults: UserDefaults
    private let minSessionsBeforePrompt = 8
    private let cooldownDays = 45
    private let maxPromptCount = 6

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func registerSessionAndShouldPrompt() -> Bool {
        guard defaults.bool(forKey: Keys.hasRated) == false else {
            return false
        }

        let sessionCount = defaults.integer(forKey: Keys.activeSessionCount) + 1
        defaults.set(sessionCount, forKey: Keys.activeSessionCount)

        guard sessionCount >= minSessionsBeforePrompt else {
            return false
        }

        let promptCount = defaults.integer(forKey: Keys.promptCount)
        guard promptCount < maxPromptCount else {
            return false
        }

        if let lastPromptDate = defaults.object(forKey: Keys.lastPromptDate) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            guard daysSinceLastPrompt >= cooldownDays else {
                return false
            }
        }

        defaults.set(Date(), forKey: Keys.lastPromptDate)
        defaults.set(promptCount + 1, forKey: Keys.promptCount)
        return true
    }

    func markUserRated() {
        defaults.set(true, forKey: Keys.hasRated)
    }

    func requestInAppReviewIfPossible() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }

        AppStore.requestReview(in: scene)
    }

    func feedbackEmailURL() -> URL? {
        let subject = "Rodeo Daily Feedback"
        let body = "Hi Rodeo Daily team,\n\n"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:thewaymediaco@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)")
    }

    func openFeedbackEmail() {
        guard let url = feedbackEmailURL() else { return }
        UIApplication.shared.open(url)
    }
}
