// -*- mode:swift -*-

import UIKit
import MediaPlayer
import AVFoundation

class ViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var artworkImageView: UIImageView!

    let TIMERINTERVAL = 0.5

    var mediaItem: MPMediaItem?
    var player: Player?
    var timer: NSTimer?
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        resetPlayer()
        playButton.enabled = false;
        titleLabel.text = "(no music)"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        resignFirstResponder()
    }

    // MARK: UIResponder
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .RemoteControl {
            switch event.subtype {
            case .RemoteControlPlay:
                startPlayer()
            case .RemoteControlPause:
                stopPlayer()
            case .RemoteControlStop:
                stopPlayer()
            case .RemoteControlTogglePlayPause:
                togglePlayer()
            default:
                println("UIResponder: not supported")
            }
        }
    }
}

// MARK: Custom Logic
extension ViewController {
    @IBAction func pressPicker(sender: UIButton) {
        stopPlayer();

        var picker = MPMediaPickerController(mediaTypes:.Music)
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = false
        picker.prompt = "music picker"

        presentViewController(picker, animated:true, completion:nil);
    }

    @IBAction func pressPlay(sender: UIButton) {
        togglePlayer()
    }

    func togglePlayer() {
        assert(mediaItem != nil, "mediaItem must be exist.")
        assert(player != nil, "player must be exist.")
        if mediaItem == nil || player == nil {
            resetPlayer()
            return
        }

        var p = player!
        if (p.playing) {
            stopPlayer()
        } else {
            startPlayer()
        }
    }

    func resetPlayer() {
        stopPlayer()
        player = nil
        playButton.enabled = false
        artworkImageView.image = nil
    }

    func createPlayer() {
        if mediaItem == nil {
            return
        }

        player = Player.createPlayer(mediaItem!)
    }

    func startPlayer() {
        if let p = player {
            p.play()
            playButton.setTitle("Stop", forState:.Normal);
            startTimer()
        }
    }

    func stopPlayer() {
        if let p = player {
            p.stop()
            playButton.setTitle("Play", forState:.Normal)
            stopTimer()
        }
    }

    func updateCounter() {
        UIApplication.sharedApplication().applicationIconBadgeNumber =
          ++counter
    }

    // MARK: Private
    private func startTimer() {
        if let t = timer {
            t.invalidate()
        }
        timer =
          NSTimer.scheduledTimerWithTimeInterval(0.5,
            target:self, selector:Selector("updateCounter"),
            userInfo:nil, repeats:true)
    }

    private func stopTimer() {
        if let t = timer {
            t.invalidate()
        }
        timer = nil
    }
}

// MARK: MPMediaPickerControllerDelegate
extension ViewController : MPMediaPickerControllerDelegate {
    func mediaPicker(mediaPicker: MPMediaPickerController!,
      didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        func completion() {
            dismissViewControllerAnimated(true, completion:nil)
        }

        playButton.enabled = false
        mediaItem = nil
        if (mediaItemCollection.items.count <= 0) {
            completion()
            return
        }

        var i: MPMediaItem = mediaItemCollection.items[0] as MPMediaItem
        var b = i.valueForProperty(MPMediaItemPropertyIsCloudItem) as NSNumber
        if (b.boolValue) {
            titleLabel.text = "(sorry, not on the device)"
            resetPlayer()
            completion()
            return
        }

        mediaItem = i
        createPlayer()
        titleLabel.text =
          i.valueForProperty(MPMediaItemPropertyTitle) as? String
        playButton.setTitle("Play", forState:.Normal)
        playButton.enabled = true
        var img: UIImage! =
          player?.artwork?.imageWithSize(artworkImageView.frame.size)
        artworkImageView.contentMode = .ScaleAspectFit
        artworkImageView.clipsToBounds = true
        artworkImageView.image = img

        println("title: \(titleLabel.text)")
        println(
          "URL: \(mediaItem?.valueForProperty(MPMediaItemPropertyAssetURL))")

        completion()
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        dismissViewControllerAnimated(true, completion:nil)
    }
}
