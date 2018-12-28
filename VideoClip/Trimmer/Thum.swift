//
//  Thum.swift
//  CCPVideoClip
//
//  Created by 储诚鹏 on 2018/12/27.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

enum ThumPosition {
    case left
    case right
}

final class Thum: UIView {
    private var img: UIImage?
    private var position: ThumPosition = .left
    private var bgColor: UIColor = .black
    private var arrowColor: UIColor = .white
    
    init(frame: CGRect, position: ThumPosition = .left, bgColor: UIColor = .black, arrowColor: UIColor = .white) {
        self.position = position
        self.bgColor = bgColor
        self.arrowColor = arrowColor
        super.init(frame: frame)
    }
    
    init(frame: CGRect, image: UIImage) {
        self.img = image
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if img == nil {
            rectTangle(rect)
            arrow(rect)
        }
        else {
            img?.draw(in: rect)
        }
    }
    
    private func arrow(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let pts = (position == .left) ? arrowLeftPoints(rect) : arrowRightPoints(rect)
        ctx?.move(to: pts.0)
        ctx?.addLines(between: pts.1)
        ctx?.setLineWidth(1.5)
        ctx?.setStrokeColor(arrowColor.cgColor)
    }
    
    private func arrowLeftPoints(_ rect: CGRect) -> (CGPoint, [CGPoint]) {
        let x = rect.width - 3
        let pt0 =  CGPoint(x: x, y: 5)
        let pt1 = CGPoint(x: 3, y: rect.height / 2)
        let pt2 = CGPoint(x: x, y: rect.height - 10)
        return (pt0, [pt1, pt2])
    }
    
    private func arrowRightPoints(_ rect: CGRect) -> (CGPoint, [CGPoint]) {
        let pt0 =  CGPoint(x: 3, y: 5)
        let pt1 = CGPoint(x: rect.width - 3, y: rect.height / 2)
        let pt2 = CGPoint(x: 3, y: rect.height - 10)
        return (pt0, [pt1, pt2])
    }
    
    private func rectTangle(_ rect: CGRect) {
        let boundedRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        let roundingCorners: UIRectCorner = (position == .left) ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight]
        let rectPath = UIBezierPath(roundedRect: boundedRect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: 3, height: 3))
        rectPath.close()
        bgColor.setFill()
        rectPath.fill()
    }
}
