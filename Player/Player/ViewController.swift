//
//  ViewController.swift
//  Player
//
//  Created by Jackie basss on 23.04.2021.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    
    let pVC = AVPlayerViewController()
    let item = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    lazy var player = AVPlayer(url: URL(string: item)!)

    // MARK: -Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRemoteTransportControls()
        setupPlaybackApearence()
        pVC.player = self.player
        pVC.allowsPictureInPicturePlayback = false
        pVC.updatesNowPlayingInfoCenter = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.present(pVC, animated: true) {
            self.pVC.player?.play()
        }
    }
    
    // MARK: -MPRemoteControll
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                setupPlaybackApearence()
                return .success
            }
            return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                player.pause()
                setupPlaybackApearence()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            self.player.seek(to: self.player.currentTime() + CMTime(seconds: 10, preferredTimescale: 1))
            return .success
        }
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            self.player.seek(to: self.player.currentTime() - CMTime(seconds: 10, preferredTimescale: 1))
            setupPlaybackApearence()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(
            self, action: #selector(changePlaybackPositionCommand(_:)))
    }
    
    func setupPlaybackApearence() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = item
        
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else { return }
        
        if let image = getThumbnailImage(forUrl: url) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =         player.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    // MARK: scrubber action
    @objc func changePlaybackPositionCommand(_ event:
                                                MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        let time = event.positionTime
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        print(time)
        return MPRemoteCommandHandlerStatus.success
    }
    
    
    // MARK: take thumbmnail image for preview
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
}

