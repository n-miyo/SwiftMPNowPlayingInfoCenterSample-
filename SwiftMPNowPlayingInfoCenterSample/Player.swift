// -*- mode:swift -*-

import AVFoundation
import MediaPlayer

class Player {
    private var avAudioPlayer: AVAudioPlayer
    private var mediaItem: MPMediaItem

    var playing: Bool {
    get {
        return avAudioPlayer.playing
    }
    }

    var artwork: MPMediaItemArtwork? {
    get {
        return mediaItem.valueForProperty(MPMediaItemPropertyArtwork)
            as? MPMediaItemArtwork
    }
    }

    class func createPlayer(mediaItem: MPMediaItem) -> Player? {
        var p: Player? = nil

        if let u: NSURL =
          mediaItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL {
            p = Player(mediaItem:mediaItem, contentsOfURL:u)
        }
        return p
    }

    func play() {
        setNowPlayingInfo(true)
        avAudioPlayer.play()
    }

    func stop() {
        setNowPlayingInfo(false)
        avAudioPlayer.stop()
    }

    func seek(currentTime: NSTimeInterval) {
        avAudioPlayer.currentTime = currentTime
    }

    // MARK: private
    private init(mediaItem item:MPMediaItem, contentsOfURL url: NSURL) {
        avAudioPlayer = AVAudioPlayer(contentsOfURL:url, error:nil)
        mediaItem = item
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayback, error:nil)
        audioSession.setActive(true, error:nil)
    }

    private func setNowPlayingInfo(playing: Bool) {
        var aw = self.artwork
        var t =
          mediaItem.valueForProperty(MPMediaItemPropertyTitle) as? NSString
        var at =
          mediaItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as? NSString
        var a =
          mediaItem.valueForProperty(MPMediaItemPropertyArtist) as? NSString
        var pd =
          mediaItem.valueForProperty(MPMediaItemPropertyPlaybackDuration)
          as? NSTimeInterval

        var playbackRate = playing ? 1.0 : 0.0
        var d: [NSObject: AnyObject] =
          [MPNowPlayingInfoPropertyPlaybackRate: playbackRate]
        d[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
          avAudioPlayer.currentTime

        if aw != nil {
            d[MPMediaItemPropertyArtwork] = aw
        }
        if t != nil {
            d[MPMediaItemPropertyTitle] = t
        }
        if at != nil {
            d[MPMediaItemPropertyAlbumTitle] = at
        }
        if a != nil {
            d[MPMediaItemPropertyArtist] = a
        }
        if pd != nil {
            d[MPMediaItemPropertyPlaybackDuration] = pd
        }

        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = d
    }
}
