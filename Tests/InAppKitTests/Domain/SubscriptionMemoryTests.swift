import Testing
import Foundation
@testable import InAppKit

@Suite
struct GracePeriodTests {

    @Test
    func `hours converts to correct TimeInterval`() {
        let grace = GracePeriod.hours(24)
        #expect(grace.duration == 86400)
    }

    @Test
    func `days converts to correct TimeInterval`() {
        let grace = GracePeriod.days(7)
        #expect(grace.duration == 604800)
    }

    @Test
    func `weeks converts to correct TimeInterval`() {
        let grace = GracePeriod.weeks(2)
        #expect(grace.duration == 1209600)
    }

    @Test
    func `none has zero duration`() {
        #expect(GracePeriod.none.duration == 0)
    }

    @Test
    func `grace periods with same duration are equal`() {
        #expect(GracePeriod.hours(168) == GracePeriod.weeks(1))
    }
}

@Suite
struct RememberedSubscriptionTests {

    private let baseDate = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func `expiresAt is rememberedAt plus gracePeriod`() {
        let sub = RememberedSubscription(
            productId: "com.app.pro",
            rememberedAt: baseDate,
            gracePeriod: 86400
        )

        #expect(sub.expiresAt == baseDate.addingTimeInterval(86400))
    }

    @Test
    func `isValid returns true within grace period`() {
        let sub = RememberedSubscription(
            productId: "com.app.pro",
            rememberedAt: baseDate,
            gracePeriod: 86400
        )

        let withinGrace = baseDate.addingTimeInterval(43200) // 12 hours later
        #expect(sub.isValid(at: withinGrace))
    }

    @Test
    func `isValid returns false after grace period expires`() {
        let sub = RememberedSubscription(
            productId: "com.app.pro",
            rememberedAt: baseDate,
            gracePeriod: 86400
        )

        let afterGrace = baseDate.addingTimeInterval(86401) // 1 second after
        #expect(!sub.isValid(at: afterGrace))
    }

    @Test
    func `isValid returns false at exact expiry time`() {
        let sub = RememberedSubscription(
            productId: "com.app.pro",
            rememberedAt: baseDate,
            gracePeriod: 86400
        )

        #expect(!sub.isValid(at: sub.expiresAt))
    }
}

@Suite
struct SubscriptionMemoryTests {

    private let baseDate = Date(timeIntervalSince1970: 1_000_000)
    private let sevenDays: TimeInterval = 604800

    // MARK: - Empty Memory

    @Test
    func `empty memory has no valid IDs`() {
        let memory = SubscriptionMemory()
        #expect(memory.validProductIDs(at: baseDate).isEmpty)
    }

    @Test
    func `empty memory has no memory`() {
        let memory = SubscriptionMemory()
        #expect(!memory.hasAnyMemory(at: baseDate))
    }

    @Test
    func `empty memory does not remember any product`() {
        let memory = SubscriptionMemory()
        #expect(!memory.isRemembered("com.app.pro", at: baseDate))
    }

    // MARK: - Adding Memories

    @Test
    func `withRemembered adds subscription with correct expiry`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)

        #expect(memory.isRemembered("com.app.pro", at: baseDate))
        #expect(memory.validProductIDs(at: baseDate) == ["com.app.pro"])
        #expect(memory.hasAnyMemory(at: baseDate))
    }

    @Test
    func `withRemembered multiple products adds all`() {
        let memory = SubscriptionMemory()
            .withRemembered(["com.app.pro", "com.app.premium"], at: baseDate, gracePeriod: sevenDays)

        #expect(memory.validProductIDs(at: baseDate) == ["com.app.pro", "com.app.premium"])
    }

    @Test
    func `withRemembered replaces existing subscription for same product`() {
        let laterDate = baseDate.addingTimeInterval(86400)
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)
            .withRemembered("com.app.pro", at: laterDate, gracePeriod: sevenDays)

        let sub = memory.subscriptions["com.app.pro"]!
        #expect(sub.rememberedAt == laterDate)
    }

    // MARK: - Expiry

    @Test
    func `remembered subscription is valid within grace period`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)

        let threeDaysLater = baseDate.addingTimeInterval(3 * 86400)
        #expect(memory.isRemembered("com.app.pro", at: threeDaysLater))
    }

    @Test
    func `remembered subscription is invalid after grace period`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)

        let eightDaysLater = baseDate.addingTimeInterval(8 * 86400)
        #expect(!memory.isRemembered("com.app.pro", at: eightDaysLater))
    }

    @Test
    func `validProductIDs only returns non-expired subscriptions`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)
            .withRemembered("com.app.basic", at: baseDate, gracePeriod: 86400) // 1 day

        let twoDaysLater = baseDate.addingTimeInterval(2 * 86400)
        #expect(memory.validProductIDs(at: twoDaysLater) == ["com.app.pro"])
    }

    // MARK: - Removing Memories

    @Test
    func `withoutMemory removes specific subscription`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)
            .withRemembered("com.app.basic", at: baseDate, gracePeriod: sevenDays)
            .withoutMemory("com.app.pro")

        #expect(!memory.isRemembered("com.app.pro", at: baseDate))
        #expect(memory.isRemembered("com.app.basic", at: baseDate))
    }

    @Test
    func `pruned removes expired subscriptions`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)
            .withRemembered("com.app.basic", at: baseDate, gracePeriod: 86400) // 1 day

        let twoDaysLater = baseDate.addingTimeInterval(2 * 86400)
        let pruned = memory.pruned(at: twoDaysLater)

        #expect(pruned.subscriptions.count == 1)
        #expect(pruned.isRemembered("com.app.pro", at: twoDaysLater))
        #expect(!pruned.isRemembered("com.app.basic", at: twoDaysLater))
    }

    @Test
    func `cleared removes all subscriptions`() {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)
            .withRemembered("com.app.basic", at: baseDate, gracePeriod: sevenDays)
            .cleared()

        #expect(memory.subscriptions.isEmpty)
        #expect(!memory.hasAnyMemory(at: baseDate))
    }

    // MARK: - Codable

    @Test
    func `SubscriptionMemory round-trips through JSON`() throws {
        let memory = SubscriptionMemory()
            .withRemembered("com.app.pro", at: baseDate, gracePeriod: sevenDays)

        let data = try JSONEncoder().encode(memory)
        let decoded = try JSONDecoder().decode(SubscriptionMemory.self, from: data)

        #expect(decoded == memory)
    }
}
