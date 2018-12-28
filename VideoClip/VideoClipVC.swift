//
//  VideoClipVC.swift
//  CCPVideoClip
//
//  Created by 储诚鹏 on 2018/12/26.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import Photos

class VideoClipVC: UIViewController {
    @IBOutlet weak var clipView: UIView!
    @IBOutlet weak var preview: UIView!
    private var player: AVPlayer?
    private var asset: PHAsset?
    
    static func creator(_ asset: PHAsset) -> VideoClipVC {
        let vc = VideoClipVC(nibName: "VideoClipVC", bundle: nil)
        vc.asset = asset
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
    }
    @IBAction func play(_ sender: Any) {
    }
    @IBAction func commit(_ sender: Any) {
    }
    
    private func setupPlayer(_ asset: PHAsset) {
        fetchItem(asset) { (item) in
            let player = AVPlayer(playerItem: item)
            player.actionAtItemEnd = .none
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.contentsGravity = .resizeAspect
            self.preview.layer.addSublayer(playerLayer)
            self.player = player
            
        }
    }
    
    private func fetchItem(_ asset: PHAsset, _ completion: @escaping (AVPlayerItem?)->()) {
        let mainCompletion: (AVPlayerItem?)->() = { item in
            DispatchQueue.main.async {
                completion(item)
            }
        }
        
        CCPVideoClipperQueue.async {
            let options = PHVideoRequestOptions()
            options.version = .original
            options.deliveryMode = .automatic
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { (item, _) in
                mainCompletion(item)
            }
        }
    }

    
}
