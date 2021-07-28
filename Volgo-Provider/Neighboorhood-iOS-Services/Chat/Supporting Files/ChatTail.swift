//
//  ChatTail.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 14/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import UIKit

class ChatRightTail: UIView {
    
    let bezierPath = UIBezierPath()
    let receiverChatColor = UIColor(red: 38/255, green: 203/255, blue: 147/255, alpha: 1)

    override func draw(_ rect: CGRect) {
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: rect.maxX))
        bezierPath.addLine(to: CGPoint(x: rect.maxY, y: 0))
        receiverChatColor.setFill()
        bezierPath.fill()
        bezierPath.close()
    }

}

class ChatLeftTail: UIView {
    
    let bezierPath = UIBezierPath()
    let senderChatColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    
    override func draw(_ rect: CGRect) {
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: rect.maxY, y: 0))
        bezierPath.addLine(to: CGPoint(x: rect.maxY, y: rect.maxY))
        senderChatColor.setFill()
        bezierPath.fill()
        bezierPath.close()
    }
    
}

