import SwiftUI
import WatchKit

@main
struct heartsignalWatch_Watch_AppApp: App {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @StateObject private var healthManager = HealthKitManager()
    private let bgSession = BackgroundSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
                .environmentObject(healthManager)
                .onAppear {
                    bgSession.start()
                    healthManager.startHeartRateMonitoring { bpm in
                        connectivity.sendHeartRate(bpm)
                    }
                }
        }
    }
}

// MARK: - 백그라운드 세션 관리 (앱이 백그라운드 가도 실행 유지)

class BackgroundSessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?

    func start() {
        guard session == nil || session?.state == .invalid else { return }
        let s = WKExtendedRuntimeSession()
        s.delegate = self
        s.start()
        session = s
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    // 만료 직전에 새 세션으로 교체
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let s = WKExtendedRuntimeSession()
        s.delegate = self
        s.start()
        session = s
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        session = nil
    }
}
