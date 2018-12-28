//
//  VideoClip.swift
//  CCPVideoClip
//
//  Created by 储诚鹏 on 2018/12/26.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import AVFoundation

public struct ClipModel {
    private(set) var url: URL
    private(set) var length: Int?
    private(set) var videoData: Data?
    init(_ url: URL) {
        self.url = url
        let data = try? Data(contentsOf: url)
        self.videoData = data
        self.length = data?.count
    }
    
}

public typealias VideoClipCallback = ((_ model: ClipModel)->())
let CCPVideoClipperQueue = DispatchQueue(label: "CCPVideoClipperQueue")

public protocol CCPVideoClipper {
    //剪辑成功后的回调
    var clipCallback: VideoClipCallback { get }
    /* 区分不同功能模块的剪辑后存储路径
     * 如果不实现，则取默认值
     */
    var exName: String { get }
    func clip(_ asset: AVURLAsset, _ timeRange: CMTimeRange)
    //清除当前(exName标记)的模块下所有已剪辑的视频
    func cleanEx()
    //清除所有已剪辑视频
    func cleanAll()
}

extension CCPVideoClipper {
    func clip(_ asset: AVURLAsset, _ timeRange: CMTimeRange) {
        VideoClip.defalut.clip(asset, timeRange, exName)
    }
    
    var exName: String { return "default" }
    
    func cleanEx() {
        VideoClip.defalut.clean(exName)
    }
    
    func cleanAll() {
        VideoClip.defalut.clean(nil)
    }
}

fileprivate final class VideoClip {
    
    var clipCallback: VideoClipCallback?
    
    //使用单例确保只有一个clipper在运行
    static let `defalut` = VideoClip()
    private init() {}
    private let dictoryPath = NSTemporaryDirectory() + "/ccp/clipvideos/"
    
    fileprivate func clip(_ asset: AVURLAsset, _ timeRange: CMTimeRange, _ ex: String) {
        let mainCallback: VideoClipCallback = { (model) in
            DispatchQueue.main.async {
               self.clipCallback?(model)
            }
        }
        
        CCPVideoClipperQueue.async {
            guard let filePath = self.savePath(asset.url, timeRange, ex) else { return }
            guard let url = URL(string: filePath) else { return }
            if FileManager.default.fileExists(atPath: filePath) { return mainCallback(ClipModel(url))}
            if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
            {
                exportSession.outputFileType = .mp4
                exportSession.outputURL = url
                exportSession.timeRange = timeRange
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        mainCallback(ClipModel(url))
                    case .failed:()
                    mainCallback(ClipModel(asset.url))
                    default: ()
                    }
                }
            }
        }
    }
    
    private func savePath(_ url: URL, _ timeRange: CMTimeRange, _ ex: String) -> String? {
        let timeKey = "\(timeRange.start.value)/\(timeRange.end.value)/"
        if let directoryPath = createDirectory(ex) {
            return directoryPath + timeKey + url.lastPathComponent
        }
        return nil
    }
    
    private func createDirectory(_ ex: String) -> String? {
        let path = dictoryPath + "\(ex)/"
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            }
            catch let error {
                print("🌹🌹🌹CCPVideoClip:" + error.localizedDescription)
                return nil
            }
        }
        return path
    }

    //ex == nil时清除全部已经剪辑并缓存到本地的视频
    func clean(_ ex: String?) {
        var path = dictoryPath
        if let name = ex {
            path += "\(name)/"
        }
        try? FileManager.default.removeItem(atPath: path)
    }
}
