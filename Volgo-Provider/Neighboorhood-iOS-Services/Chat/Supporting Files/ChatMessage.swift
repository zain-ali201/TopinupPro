//
//  ChatMessage.swift
//  ChatKit
//
//  Created by Sarim Ashfaq on 11/08/2019.
//  Copyright © 2019 Sarim Ashfaq. All rights reserved.
//

import Foundation

enum MessageState {
    case sent, delivered, read, waiting, failed
}

enum MessageType {
    case text, media, audio
}

struct ChatMessage {
    var messageID: String = ""
    var date: Date = Date()
    var senderID: Int = 0
    var senderImage: String = ""
    var isCurrentUser: Bool = false
    var type: MessageType = .text
    var mediaURL: String = ""
    var message: String = ""
    var state: MessageState = .sent
}
