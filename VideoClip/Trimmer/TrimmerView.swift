//
//  TrimmerView.swift
//  CCPVideoClip
//
//  Created by 储诚鹏 on 2018/12/27.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import Photos

class TrimmerView: UIView {
    private let asset: AVAsset
    private let frameView = UIView()
    private var thumWidth: CGFloat = 10
    private var widthPerSec: CGFloat = 0
    private let boardWidth: CGFloat = 1
    private let boardColor = UIColor.orange
    
    init(_ frame: CGRect, _ asset: AVAsset) {
        self.asset = asset
        super.init(frame: frame)
        self.setupContents()
        self.setupBoardView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContents() {
        frameView.frame = CGRect(x: thumWidth, y: 0, width: frame.width - 2 * thumWidth, height: frame.height)
        setupFrames()
    }
    
    private func setupBoardView() {
        boardView(0)
        boardView(self.bounds.height - boardWidth)
    }
    
    private func boardView(_ y: CGFloat) {
        let frame = CGRect(x: thumWidth, y: y, width: frameView.bounds.width, height: boardWidth)
        let view = UIView(frame: frame)
        view.backgroundColor = boardColor
        self.addSubview(view)
    }
    
    private func setupFrames() {
        CCPVideoClipperQueue.async {
            let imgGenerator = self.imageGenerator()
            let videoShot = self.videoShot(imgGenerator)
            guard let picWidth = videoShot?.size.width else { return }
            let duration = self.asset.duration.seconds
            let frameWidth = self.frameView.bounds.width
            self.widthPerSec = frameWidth / CGFloat(duration)
            let pics = Int(frameWidth / picWidth) + 1
            self.videoShots(imgGenerator, pics, { (imgs) in
                var x: CGFloat = 0
                for img in imgs {
                    let frame = CGRect(origin: CGPoint(x: x, y: 0), size: img.size)
                    let imgv = UIImageView(frame: frame)
                    imgv.image = img
                    x += img.size.width
                    self.frameView.addSubview(imgv)
                }
            })
        }
    }
    
    private func imageGenerator() -> AVAssetImageGenerator {
        let imgGenerator = AVAssetImageGenerator(asset: self.asset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.maximumSize = CGSize(width: self.bounds.width * 2, height: self.bounds.height * 2)
        return imgGenerator
    }
    
    private func videoShots(_ imgGenerator: AVAssetImageGenerator, _ picCount: Int, _ completion: @escaping ([UIImage]) -> ()) {
        var images = [UIImage]()
        for i in 0 ..< picCount {
            let time = CMTime(seconds: Double(i), preferredTimescale: 600)
            if let image = videoShot(imageGenerator(), time) {
                images.append(image)
            }
        }
        DispatchQueue.main.async {
            completion(images)
        }
    }
    
    private func videoShot(_ imgGenerator: AVAssetImageGenerator, _ time: CMTime = .zero) -> UIImage? {
        guard let halfImg = try? imgGenerator.copyCGImage(at: time, actualTime: nil) else  { return nil }
        return UIImage(cgImage: halfImg, scale: 2.0, orientation: .up)
    }
    

}
