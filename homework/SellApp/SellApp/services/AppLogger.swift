import Foundation
import OSLog

struct AppLogger {

    private enum Constants {
        static let subsystem = Bundle.main.bundleIdentifier ?? ""
    }

    static let network = Logger(subsystem: Constants.subsystem, category: "network")
    static let auth = Logger(subsystem: Constants.subsystem, category: "auth")
    static let p2p = Logger(subsystem: Constants.subsystem, category: "p2p")
}
