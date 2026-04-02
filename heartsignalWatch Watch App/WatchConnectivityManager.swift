import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var heartRate: Double = 0
    @Published var partnerHeartRate: Double = 0
    @Published var isPhoneReachable: Bool = false
    @Published var currentStatus: String = ""

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendHeartRate(_ bpm: Double) {
        // updateApplicationContext는 앱이 백그라운드/비활성 상태에서도 전달됨
        let context: [String: Any] = ["heartRate": bpm, "ts": Date().timeIntervalSince1970]
        try? WCSession.default.updateApplicationContext(context)
        // 앱이 활성 상태면 즉시 전달도 병행
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["heartRate": bpm], replyHandler: nil)
        }
    }

    func sendStatus(_ status: String) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["status": status], replyHandler: nil)
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let bpm = message["partnerHeartRate"] as? Double {
                self.partnerHeartRate = bpm
            }
            if let status = message["status"] as? String {
                self.currentStatus = status
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            if let bpm = applicationContext["partnerHeartRate"] as? Double {
                self.partnerHeartRate = bpm
            }
        }
    }
}
