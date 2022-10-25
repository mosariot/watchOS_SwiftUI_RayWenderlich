import Foundation
import HealthKit

final class HealthStore {
  static let shared = HealthStore()
  private var healthStore: HKHealthStore?
  private let brushingCategoryType = HKCategoryType.categoryType(forIdentifier: .toothbrushingEvent)!
  private let waterQuantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
  private let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
  
  var isWaterEnabled: Bool {
    let status = healthStore?.authorizationStatus(for: waterQuantityType)
    return status == .sharingAuthorized
  }
  
  private init() {
    guard HKHealthStore.isHealthDataAvailable() else { return }
    healthStore = HKHealthStore()
    Task {
      try await healthStore!.requestAuthorization(
        toShare: [brushingCategoryType, waterQuantityType],
        read: [brushingCategoryType, waterQuantityType, bodyMassType]
      )
      await MainActor.run {
        NotificationCenter.default.post(name: .healthStoreLoaded, object: nil)
      }
    }
  }
  
  func logBrushing(startDate: Date) async throws {
    let status = healthStore?.authorizationStatus(for: brushingCategoryType)
    guard status == .sharingAuthorized else { return }
    let sample = HKCategorySample(
      type: brushingCategoryType,
      value: HKCategoryValue.notApplicable.rawValue,
      start: startDate,
      end: Date.now
    )
    try await save(sample)
  }
  
  func logWater(quantity: HKQuantity) async throws {
    guard isWaterEnabled else { return }
    let sample = HKQuantitySample(
      type: waterQuantityType,
      quantity: quantity,
      start: Date.now,
      end: Date.now
    )
    try await save(sample)
  }
  
  private func currentBodyMass() async throws -> Double? {
    guard let healthStore else {
      throw HKError(.errorHealthDataUnavailable)
    }
    let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
        guard let latest = samples?.first as? HKQuantitySample else {
          continuation.resume(returning: nil)
          return
        }
        let pounds = latest.quantity.doubleValue(for: .pound())
        continuation.resume(returning: pounds)
      }
      healthStore.execute(query)
    }
  }
  
  private func save(_ sample: HKSample) async throws {
    guard let healthStore else {
      throw HKError(.errorHealthDataUnavailable)
    }
    let _: Bool = try await withCheckedThrowingContinuation { continuation in
      healthStore.save(sample) { _, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        continuation.resume(returning: true)
      }
    }
  }
}
