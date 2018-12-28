//
//  Ruler.swift
//  CCPVideoClip
//
//  Created by 储诚鹏 on 2018/12/27.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class Ruler: UIView {
    private let marginH: CGFloat = 10.0
    private let marginV: CGFloat = 0.0
    private var widthPerSecond: CGFloat = 25
    private let majorTickLength: CGFloat = 12.0
    private let minjorTickLength: CGFloat = 7.0
    private var multiple: Int = 1
    private let themeColor = UIColor.gray
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(themeColor.cgColor)
        let y = marginV + rect.height
        let majorY = y - majorTickLength
        let minorY = y - minjorTickLength
        var step: Int = 0
        var skipCount: Int = 0
        let shouldSkip = widthPerSecond < 4.75
        var x: CGFloat = 0
        
        let attrs: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 11), .foregroundColor : themeColor]
        
        func drawElement(_ x: CGFloat) {
            if multiple == 0 { fatalError("CCPVideoClip:multiple can't be 0") }
            if step % multiple == 0 {
                ctx?.fill(CGRect(x: x, y: majorY, width: 1.75, height: majorTickLength))
                drawAttributeString(x - 7)
            }
            else {
                ctx?.fill(CGRect(x: x, y: minorY, width: 1.0, height: minjorTickLength))
            }
        }
        
        func drawAttributeString(_ x: CGFloat) {
            let min = step / 60
            let sec = step % 60
            let string = String(NSString(format: "%02d:%02d", min, sec))
            let attributeString = NSAttributedString(string: string, attributes: attrs)
            attributeString.draw(at: CGPoint(x: x, y: majorY - 15))
        }
        
        while x <= marginH + rect.width  {
            x += widthPerSecond
            ctx?.move(to: CGPoint(x: x, y: y))
            if shouldSkip && skipCount == 5 {
                skipCount = 0
                drawElement(x)
            }
            else if shouldSkip {
                skipCount += 1
            }
            else {
                drawElement(x)
            }
            step += 1
        }
    }

}
