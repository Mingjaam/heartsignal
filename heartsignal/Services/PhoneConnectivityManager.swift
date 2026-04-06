import Foundation
import WatchConnectivity
import HealthKit
internal import Combine

class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published var isWatchReachable: Bool = false
    @Published var watchHeartRate: Double = 0
    @Published var partnerHeartRate: Double = 0

    private let healthStore = HKHealthStore()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        startHealthKitMonitoring()
    }

    // MARK: - HealthKit으로 내 심박수 직접 읽기 (워치 앱 없어도 동작)

    private func startHealthKitMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, _ in
            guard success else { return }
            // 백그라운드 딜리버리 활성화 (앱이 꺼져 있어도 업데이트 수신)
            self.healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
            // 새 심박 데이터가 생길 때마다 호출되는 옵저버
            let observer = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
                guard error == nil else { return }
                self?.fetchLatestHeartRate()
            }
            self.healthStore.execute(observer)
            // 앱 시작 시 최신값 즉시 로드
            self.fetchLatestHeartRate()
        }
    }

    private func fetchLatestHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self?.watchHeartRate = bpm
            }
        }
        healthStore.execute(query)
    }

    // 상대 심박수를 워치에 전달
    func sendPartnerHeartRate(_ bpm: Double) {
        guard WCSession.default.isReachable else {
            // 워치가 꺼져있으면 ApplicationContext로 전달 (나중에 수신)
            try? WCSession.default.updateApplicationContext(["partnerHeartRate": bpm])
            return
        }
        WCSession.default.sendMessage(["partnerHeartRate": bpm], replyHandler: nil)
    }

    // 상태 메시지를 워치에 전달
    func sendStatus(_ status: String) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["status": status], replyHandler: nil)
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            // 앱이 포그라운드가 아니어도 워치가 페어링+설치되면 연결로 표시
            self.isWatchReachable = session.isPaired && session.isWatchAppInstalled
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        // reachability 변경 시에도 페어링 상태 기준으로 유지
        DispatchQueue.main.async {
            self.isWatchReachable = session.isPaired && session.isWatchAppInstalled
        }
    }

    // 워치에서 직접 전송한 메시지 수신 (포그라운드)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let bpm = message["heartRate"] as? Double {
                self.watchHeartRate = bpm
            }
        }
    }

    // 워치가 백그라운드일 때 updateApplicationContext로 전달된 심박수 수신
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            if let bpm = applicationContext["heartRate"] as? Double {
                self.watchHeartRate = bpm
            }
        }
    }

    // iOS 전용 필수 델리게이트
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
