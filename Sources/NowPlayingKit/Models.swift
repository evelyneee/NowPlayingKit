//
//  Models.swift
//  
//
//  Created by evelyn on 2022-10-15.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#elseif canImport(WatchKit)
import WatchKit
public typealias PlatformImage = WKImage
#endif

public struct Song: Codable, Identifiable, Sendable {
    
    public var name: String
    public var id: Int64
    public var trackNumber: Int?
    public var duration: Double
    
    public var album: Album
            
    public var artist: Artist? { self.album.artist }
    public var artists: [Artist] { self.album.artists }
}

public struct Album: Codable, Identifiable, Sendable {
    
    public var name: String
    public var id: Int64
    
    public var artwork: Data?
    
    @MainActor
    public var artworkImage: PlatformImage? {
        if let artwork {
            return PlatformImage(data: artwork)
        }
        return nil
    }
    
    public var trackCount: Int?
    public var genre: String?
    public var mainArtist: Artist?
    public var artist: Artist? { mainArtist ?? self.artists.first }
    public var artists: [Artist]
    public var songs: [Song]?
    public var releaseDate: String?
}

public struct Artist: Codable, Identifiable, Hashable, Sendable {
    public var name: String
    public var id: Int64
    public var image: URL?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
}

public struct Playlist: Codable, Identifiable, Sendable {
    public var id: String { self.name }
    public var name: String
    public var songs: [Song]
    
    internal func convertToAlbum() -> Album {
        .init(name: self.name, id: 0, artwork: nil, trackCount: nil, genre: nil, mainArtist: .init(name: "", id: 1), artists: [], songs: self.songs, releaseDate: nil)
    }
}

extension Song: Hashable, Equatable {
    public static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
}

extension Album: Hashable, Equatable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
}

extension Playlist: Hashable, Equatable {
    public static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension Song {
    static func value(from dict: [String:Any]) -> (Bool, Song) {
        let playing: Bool = (dict["playbackRate"] as? Int) == 1
        let artist = Artist(
            name: (dict["trackArtistName"] as? String) ?? (dict["composer"] as? String) ?? "Unknown artist",
            id: dict["iTunesStoreArtistIdentifier"] as? Int64 ?? 0,
            image: nil
        )
        let album = Album(
            name: dict["albumName"] as? String ?? "Unknown Album",
            id: dict["iTunesStoreAlbumIdentifier"] as? Int64 ?? 0,
            artwork: nil,
            trackCount: dict["totalTrackCount"] as? Int ?? 0,
            genre: dict["genre"] as? String ?? "",
            mainArtist: artist,
            artists: [],
            songs: []
        )
        let duration = Double(String((dict["duration"] as? String)?.components(separatedBy: "(").last?.dropLast(1) ?? "")) ?? 0.0
        let song = Song(
            name: dict["title"] as? String ?? "Nothing playing",
            id: dict["iTunesStoreIdentifier"] as? Int64 ?? 0,
            trackNumber: dict["trackNumber"] as? Int ?? 0,
            duration: duration,
            album: album
        )
        return (playing, song)
    }
}
