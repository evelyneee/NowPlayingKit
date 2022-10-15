import XCTest
import Combine
@testable import NowPlayingKit

final class NowPlayingKitTests: XCTestCase {
    
    var kit: NowPlayingKit? = .init()
    
    var cancellable: AnyCancellable? = nil
    
    @available(macOS 13.0, *)
    func testSubscription() async throws {
        print("setup")
        self.cancellable = self.kit?._registerForNotifications().sink {
            print($0, "AAAAA")
        }
        dump(kit)
        try await Task.sleep(for: .seconds(20.0))
    }
    
    func testNowPlayingInfo() async throws -> Bool {
        return await withCheckedContinuation { cont in
            self.kit?.private.getNowPlayingInfo(DispatchQueue.global()) { dict in
                cont.resume(with: .success(!dict.keys.isEmpty))
            }
        }
    }
    
}
