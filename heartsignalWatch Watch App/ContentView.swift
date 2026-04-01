import SwiftUI
import HealthKit
import Combine

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @EnvironmentObject var healthManager: HealthKitManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                heartRateSection
                partnerSection
                statusSection
            }
            .padding(.horizontal, 8)
        }
        .background(Color.black)
    }

    // MARK: - 내 심박수

    private var heartRateSection: some View {
        VStack(spacing: 4) {
            Text("나")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(healthManager.heartRate > 0 ? "\(Int(healthManager.heartRate))" : "--")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
                Text("bpm")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 1, green: 0, blue: 0.55))
                    .padding(.bottom, 6)
            }

            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 1, green: 0, blue: 0.55))
                .symbolEffect(.pulse, isActive: healthManager.heartRate > 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }

    // MARK: - 상대 심박수

    private var partnerSection: some View {
        VStack(spacing: 4) {
            Text("상대")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(connectivity.partnerHeartRate > 0 ? "\(Int(connectivity.partnerHeartRate))" : "--")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
                Text("bpm")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 1, green: 0, blue: 0.55))
                    .padding(.bottom, 6)
            }

            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }

    // MARK: - 상태 메시지

    private var statusSection: some View {
        Group {
            if !connectivity.currentStatus.isEmpty {
                Text(connectivity.currentStatus)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - HealthKit Manager

class HealthKitManager: ObservableObject {
    @Published var heartRate: Double = 0

    private let healthStore = HKHealthStore()
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var onChangeCallback: ((Double) -> Void)?

    func startHeartRateMonitoring(onChange: @escaping (Double) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        self.onChangeCallback = onChange

        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, _ in
            guard success else { return }
            // 백그라운드에서도 업데이트 수신 활성화
            self.healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
            // 앱이 백그라운드일 때 시스템이 깨워줄 Observer Query
            self.startObserverQuery(heartRateType: heartRateType, onChange: onChange)
            // 포그라운드 실시간 업데이트용 Anchored Query
            self.startAnchoredQuery(heartRateType: heartRateType, onChange: onChange)
        }
    }

    private func startObserverQuery(heartRateType: HKQuantityType, onChange: @escaping (Double) -> Void) {
        let observer = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            guard error == nil else { return }
            self?.fetchLatestHeartRate(heartRateType: heartRateType, onChange: onChange)
        }
        healthStore.execute(observer)
    }

    private func fetchLatestHeartRate(heartRateType: HKQuantityType, onChange: @escaping (Double) -> Void) {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: .init(from: "count/min"))
            DispatchQueue.main.async {
                self?.heartRate = bpm
                onChange(bpm)
            }
        }
        healthStore.execute(query)
    }

    private func startAnchoredQuery(heartRateType: HKQuantityType, onChange: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        anchoredQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples, onChange: onChange)
        }
        anchoredQuery?.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples, onChange: onChange)
        }
        if let q = anchoredQuery { healthStore.execute(q) }
    }

    private func processSamples(_ samples: [HKSample]?, onChange: @escaping (Double) -> Void) {
        guard let samples = samples as? [HKQuantitySample],
              let latest = samples.last else { return }
        let bpm = latest.quantity.doubleValue(for: .init(from: "count/min"))
        DispatchQueue.main.async {
            self.heartRate = bpm
            onChange(bpm)
        }
    }
}
