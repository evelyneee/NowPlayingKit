//
//  Private.swift
//  
//
//  Created by evelyn on 2022-10-15.
//

import Foundation

class Private {
    
    internal typealias MRMediaRemoteRegisterForNowPlayingNotificationsBody = @convention (c) (DispatchQueue) -> Void
    private static let _registerForNowPlayingNotifications = "TVJNZWRpYVJlbW90ZVJlZ2lzdGVyRm9yTm93UGxheWluZ05vdGlmaWNhdGlvbnM=" // MRMediaRemoteRegisterForNowPlayingNotifications
    public let registerForNowPlayingNotifications: MRMediaRemoteRegisterForNowPlayingNotificationsBody
    
    internal typealias MRMediaRemoteGetNowPlayingInfoBody = @convention (c) (DispatchQueue, @escaping ([String:Any]) -> Void) -> Void
    private static let _getNowPlayingInfo = "TVJNZWRpYVJlbW90ZUdldE5vd1BsYXlpbmdJbmZv" // MRMediaRemoteGetNowPlayingInfo
    public let getNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoBody
    
    internal typealias MRMediaRemoteSendCommandBody = @convention (c) (UInt32, Dictionary<String, Any>?) -> Bool
    private static let __sendCommand = "TVJNZWRpYVJlbW90ZVNlbmRDb21tYW5k" // MRMediaRemoteSendCommand
    internal let _sendCommand: MRMediaRemoteSendCommandBody
    
    internal static let bundleName = "L1N5c3RlbS9MaWJyYXJ5L1ByaXZhdGVGcm" + "FtZXdvcmtzL01lZGlhUmVtb3RlLmZyYW1ld29yaw=="
    internal static let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: Private.bundleName.base64decoded))
    
    init?() {
        guard let getNowPlayingInfo = Private.getFunction(MRMediaRemoteGetNowPlayingInfoBody.self, name: Private._getNowPlayingInfo.base64decoded),
              let registerForNowPlayingNotifications = Private.getFunction(MRMediaRemoteRegisterForNowPlayingNotificationsBody.self, name: Private._registerForNowPlayingNotifications.base64decoded),
              let sendCommand = Private.getFunction(MRMediaRemoteSendCommandBody.self, name: Private.__sendCommand.base64decoded)else {
            return nil
        }
        self.getNowPlayingInfo = getNowPlayingInfo
        self.registerForNowPlayingNotifications = registerForNowPlayingNotifications
        self._sendCommand = sendCommand
    }
    
    /*
     * Use a NSDictionary for userInfo, which contains three keys:
     * kMRMediaRemoteOptionTrackID
     * kMRMediaRemoteOptionStationID
     * kMRMediaRemoteOptionStationHash
     */
    @discardableResult
    func sendCommand(_ command: MediaRemoteCommands, trackID: String? = nil, stationID: String? = nil, stationHash: String? = nil) -> Bool {
        if trackID != nil || stationID != nil || stationHash != nil {
            return _sendCommand(.init(UInt32(command.rawValue)), [
                "kMRMediaRemoteOptionTrackID":trackID as Any,
                "kMRMediaRemoteOptionStationID":stationID as Any,
                "kMRMediaRemoteOptionStationHash":stationHash as Any
            ].compactMapValues { $0 })
        }
        return _sendCommand(.init(UInt32(command.rawValue)), nil)
    }
    
    static func getFunction<T>(_ type: T.Type, name: String) -> T? {
        print(name)
        guard let ptr = CFBundleGetFunctionPointerForName(bundle, name as CFString) else { return nil }
        let fn = unsafeBitCast(ptr, to: T?.self)
        return fn
    }
}

extension String {
    var base64decoded: String {
        let data = self.data(using: .utf8)
        let decoded = Data(base64Encoded: data!)
        let string = String(data: decoded!, encoding: .utf8)
        return string!
    }
}

enum MediaRemoteCommands: Int, RawRepresentable {
    /*
     * Use nil for userInfo.
     */
    case play = 0,
    pause,
    togglePlayPause,
    stop,
    nextTrack,
    previousTrack,
    advanceShuffleMode,
    advanceRepeatMode,
    beginFastForward,
    endFastForward,
    beginRewind,
    endRewind,
    rewind15Seconds,
    fastForward15Seconds,
    rewind30Seconds,
    fastForward30Seconds,
    toggleRecord,
    skipForward,
    skipBackward,
    changePlaybackRate,

    /*
     * Use a NSDictionary for userInfo, which contains three keys:
     * kMRMediaRemoteOptionTrackID
     * kMRMediaRemoteOptionStationID
     * kMRMediaRemoteOptionStationHash
     */
    rateTrack,
    likeTrack,
    dislikeTrack,
    bookmarkTrack,

    /*
     * Use nil for userInfo.
     */
    seekToPlaybackPosition,
    changeRepeatMode,
    changeShuffleMode,
    enableLanguageOption,
    disableLanguageOption
}
