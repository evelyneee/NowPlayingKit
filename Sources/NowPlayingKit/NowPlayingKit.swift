
import Foundation

#if canImport(Combine)
import Combine
#endif

public class NowPlayingKit {
    
    internal let `private`: Private
    
    public init?() {
        if let `private` = Private() {
            self.private = `private`
        } else {
            return nil
        }
    }
    
    @MainActor
    private (set) var nowPlaying: Song? = nil
    
    #if canImport(Combine)
        
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func nowPlayingNotificationPublisher(debounceFor seconds: Double = 2.0) -> AnyPublisher<(Bool, Song), Never>{
        self.private.registerForNowPlayingNotifications(.main)
        let name = Notification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
        return NotificationCenter.default.publisher(for: name)
            .debounce(for: .seconds(seconds), scheduler: RunLoop.main)
            .compactMap { notif in
                print(notif)
                if let userInfo = notif.userInfo as? [String:Any],
                   let items = userInfo["kMRMediaRemoteUpdatedContentItemsUserInfoKey"],
                   let item = (items as? Array<NSObject>)?.first,
                   let dict = (item.perform(NSSelectorFromString("metadata")).takeUnretainedValue() as? NSObject)?.perform(NSSelectorFromString("dictionaryRepresentation")).takeUnretainedValue() as? [String:Any], !dict.isEmpty {
                    return Song.value(from: dict)
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    #endif
    
}
