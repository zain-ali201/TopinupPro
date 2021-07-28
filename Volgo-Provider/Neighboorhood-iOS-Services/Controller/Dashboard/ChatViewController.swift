////
////  ChatViewController.swift
////  SwiftExample
////
////  Created by Dan Leonard on 5/11/16.
////  Copyright © 2016 MacMeDan. All rights reserved.
////
//
//import UIKit
//import JSQMessagesViewController
//
enum MessageSourceType : String
{
    case Company = "Client"
    case Driver  = "Provider"
}
//
////enum QueryType : Int {
////
////    case MessageDispatch = 0
////    case Disputes = 1
////}
//
//class ChatViewController: JSQMessagesViewController {
//    var messages = [JSQMessage]()
//    let defaults = UserDefaults.standard
//    var conversation: Conversation?
//    var incomingBubble: JSQMessagesBubbleImage!
//    var outgoingBubble: JSQMessagesBubbleImage!
//    fileprivate var displayName: String!
////    var senderID : String!
//    var messageSourceType : MessageSourceType!
//    //var queryType : QueryType!
//    var queryMessages = [MessageThreadVO]()
//
//    var queryID = String()
//    var jobID = String()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.viewInitializer()
//    }
//
//    @objc func keyboardDismiss()
//    {
//        self.view.endEditing(true)
//    }
//
//    func setupBackButton() {
//
//        let btnLeftMenu: UIButton = UIButton()
//        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
//        self.title = "Messenger"
//        btnLeftMenu.setImage(UIImage(named: "arrowBackMessenger"), for: UIControl.State())
//        let barButton = UIBarButtonItem(customView: btnLeftMenu)
//        self.navigationItem.leftBarButtonItem = barButton
//        btnLeftMenu.addTarget(self, action: #selector(backButtonTapped), for: UIControl.Event.touchUpInside)
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 2/255, green: 196/255, blue: 130/255, alpha: 1)
//    }
//
//    @objc func backButtonTapped() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//
//        self.getJobMessages()
//    }
//
//    func viewInitializer()
//    {
//        // Setup navigation
//
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.keyboardDismiss))
//        self.view.addGestureRecognizer(tap)
//
//        setupBackButton()
//
//        self.senderId = MessageSourceType.Driver.rawValue
//        self.senderDisplayName = MessageSourceType.Driver.rawValue
//
//        self.inputToolbar.contentView.leftBarButtonItem = nil;
//
//        /**
//         *  Override point:
//         *
//         *  Example of how to cusomize the bubble appearence for incoming and outgoing messages.
//         *  Based on the Settings of the user display two differnent type of bubbles.
//         *
//         */
//
////                incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 2/255, green: 196/255, blue: 130/255, alpha: 1))
//
//        // hide for not showing images with messages
////        incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor(red: 2/255, green: 196/255, blue: 130/255, alpha: 1))
////
////        outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0))
//
//        //        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
//        //            // Make taillessBubbles
//        //
//        ////            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//        ////
//        ////
//        ////
//        ////            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).outgoingMessagesBubbleImage(with: UIColor.lightGray)
//        //
//        //
//        //
//        //
//        //            incomingBubble = JSQMessagesBubbleImage(messageBubble: UIImage.jsq_bubbleCompactTailless(), highlightedImage: UIImage.jsq_bubbleCompactTailless())
//        //
//        //            outgoingBubble = JSQMessagesBubbleImage(messageBubble: UIImage.jsq_bubbleCompactTailless(), highlightedImage: UIImage.jsq_bubbleCompactTailless())
//        //        }
//        //        else {
//                    // Bubbles with tails
//        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1))
//        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 38/255, green: 203/255, blue: 147/255, alpha: 1))
//        //        }
//
//        /**
//         *  Example on showing or removing Avatars based on user settings.
//         */
//
//        //        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
//        //        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
//
//        //
//        //        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
//        ////            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
//        ////            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
//        //        } else {
//        //            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
//        //            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
//        //        }
//        //
//        // Show Button to simulate incoming messages
//        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(receiveMessagePressed))
//
//        // This is a beta feature that mostly works but to make things more stable it is diabled.
//        collectionView?.collectionViewLayout.springinessEnabled = false
//
//        automaticallyScrollsToMostRecentMessage = true
//
//        self.collectionView?.reloadData()
//        self.collectionView?.layoutIfNeeded()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.didReceiveAddMessagesResponse(notification:)), name: NSNotification.Name.kAddMessageThread, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.didReceiveGetQueryMessagesResponse(notification:)), name: NSNotification.Name.kGetJobThreadMessages, object: nil)
//
//    }
//
//    func getJobMessages() {
//
//        if !Connection.isInternetAvailable()
//        {
//            Connection.showNetworkErrorView()
//            return;
//        }
//
//        let params = ["jobId" : jobID] as [String : Any]
//        SocketManager.shared.sendSocketRequest(name: SocketEvent.GetJobThreadMessages, params: params)
//        showProgressHud(viewController: self)
//    }
//
//    func newJobMessages(newMessage : String) {
//
//        if !Connection.isInternetAvailable()
//        {
//            Connection.showNetworkErrorView()
//            return;
//        }
//
//        let params = ["jobId" : jobID, "message" : newMessage] as [String : Any]
//        SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
//        showProgressHud(viewController: self)
//    }
//
//    @objc func didReceiveGetQueryMessagesResponse(notification : Notification)
//    {
//        let userInfo = notification.userInfo as! NSDictionary
//        print(#function , userInfo)
//
//        let suc = userInfo.value(forKey: "isSuccess") as! Bool
//        let msg = userInfo.value(forKey: "message") as! String
//        hideProgressHud(viewController: self)
//
//        if suc
//        {
//            if let queryMessagesDict = userInfo.object(forKey: "jobmessages") as? NSArray
//            {
//                self.queryMessages.removeAll()
//                self.messages.removeAll()
//
//                for item in queryMessagesDict
//                {
//                    let queryDict = MessageThreadVO(dictionary: item as! NSDictionary)
//                    queryMessages.append(queryDict)
//                }
//
//                for i in queryMessages
//                {
//                    let newMessage = JSQMessage(senderId: i.type, displayName: i.type, text: i.message)
//                    self.messages.append(newMessage!)
//                }
//
//                self.finishReceivingMessage(animated: true)
//
//            } else {
//                print("Parsing not happening")
//            }
//        }
//        else
//        {
//            //showInfoAlertWith(title: "Failed", message: msg)
//        }
//    }
//
//    @objc func didReceiveAddMessagesResponse(notification : Notification)
//    {
//        let userInfo = notification.userInfo as! NSDictionary
//        print(#function , userInfo)
//
//        let suc = userInfo.value(forKey: "isSuccess") as! Bool
//        let msg = userInfo.value(forKey: "message") as! String
//        hideProgressHud(viewController: self)
//
//        if suc
//        {
//            if let jobmessage = userInfo.object(forKey: "jobmessage") as? NSDictionary
//            {
//                let queryDict = MessageThreadVO(dictionary: jobmessage as! NSDictionary)
//                queryMessages.append(queryDict)
//
//                let newMessage = JSQMessage(senderId: queryDict.type, displayName: queryDict.type, text: queryDict.message)
//                self.messages.append(newMessage!)
//                self.finishReceivingMessage(animated: true)
//            }
//        }
//        else
//        {
//            //showInfoAlertWith(title: "Failed", message: msg)
//        }
//    }
//
//
////    func receiveMessagePressed(_ sender: UIBarButtonItem) {
////        /**
////         *  DEMO ONLY
////         *
////         *  The following is simply to simulate received messages for the demo.
////         *  Do not actually do this.
////         */
////
////        /**
////         *  Show the typing indicator to be shown
////         */
////        self.showTypingIndicator = !self.showTypingIndicator
////
////        /**
////         *  Scroll to actually view the indicator
////         */
////        self.scrollToBottom(animated: true)
////
////        /**
////         *  Copy last sent message, this will be the new "received" message
////         */
////        var copyMessage = self.messages.last?.copy()
////
////        if (copyMessage == nil) {
////
////            copyMessage = JSQMessage(senderId: MessageSourceType.Driver.rawValue, displayName: getName(User.Jobs), text: "First received!")
////        }
////
////        var newMessage:JSQMessage!
////        var newMediaData:JSQMessageMediaData!
////        var newMediaAttachmentCopy:AnyObject?
////
////        if (copyMessage! as AnyObject).isMediaMessage() {
////            /**
////             *  Last message was a media message
////             */
////            let copyMediaData = (copyMessage! as AnyObject).media
////
////            switch copyMediaData {
////            case is JSQPhotoMediaItem:
////                let photoItemCopy = (copyMediaData as! JSQPhotoMediaItem).copy() as! JSQPhotoMediaItem
////                photoItemCopy.appliesMediaViewMaskAsOutgoing = false
////
////                newMediaAttachmentCopy = UIImage(cgImage: photoItemCopy.image!.cgImage!)
////
////                /**
////                 *  Set image to nil to simulate "downloading" the image
////                 *  and show the placeholder view5017
////                 */
////                photoItemCopy.image = nil;
////
////                newMediaData = photoItemCopy
////            case is JSQLocationMediaItem:
////                let locationItemCopy = (copyMediaData as! JSQLocationMediaItem).copy() as! JSQLocationMediaItem
////                locationItemCopy.appliesMediaViewMaskAsOutgoing = false
////                newMediaAttachmentCopy = locationItemCopy.location!.copy() as AnyObject?
////
////                /**
////                 *  Set location to nil to simulate "downloading" the location data
////                 */
////                locationItemCopy.location = nil;
////
////                newMediaData = locationItemCopy;
////            case is JSQVideoMediaItem:
////                let videoItemCopy = (copyMediaData as! JSQVideoMediaItem).copy() as! JSQVideoMediaItem
////                videoItemCopy.appliesMediaViewMaskAsOutgoing = false
////                newMediaAttachmentCopy = (videoItemCopy.fileURL! as NSURL).copy() as AnyObject?
////
////                /**
////                 *  Reset video item to simulate "downloading" the video
////                 */
////                videoItemCopy.fileURL = nil;
////                videoItemCopy.isReadyToPlay = false;
////
////                newMediaData = videoItemCopy;
////            case is JSQAudioMediaItem:
////                let audioItemCopy = (copyMediaData as! JSQAudioMediaItem).copy() as! JSQAudioMediaItem
////                audioItemCopy.appliesMediaViewMaskAsOutgoing = false
////                newMediaAttachmentCopy = (audioItemCopy.audioData! as NSData).copy() as AnyObject?
////
////                /**
////                 *  Reset audio item to simulate "downloading" the audio
////                 */
////                audioItemCopy.audioData = nil;
////
////                newMediaData = audioItemCopy;
////            default:
////                assertionFailure("Error: This Media type was not recognised")
////            }
////
////            newMessage = JSQMessage(senderId: senderID, displayName: getName(User.Jobs), media: newMediaData)
////        }
////        else {
////            /**
////             *  Last message was a text message
////             */
////
////            newMessage = JSQMessage(senderId: senderID, displayName: getName(User.Jobs), text: (copyMessage! as AnyObject).text)
////        }
////
////        /**
////         *  Upon receiving a message, you should:
////         *
////         *  1. Play sound (optional)
////         *  2. Add new JSQMessageData object to your data source
////         *  3. Call `finishReceivingMessage`
////         */
////
////        self.messages.append(newMessage)
////        self.finishReceivingMessage(animated: true)
////
////        if newMessage.isMediaMessage {
////            /**
////             *  Simulate "downloading" media
////             */
////            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
////                /**
////                 *  Media is "finished downloading", re-display visible cells
////                 *
////                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
////                 *
////                 *  Reload the specific item, or simply call `reloadData`
////                 */
////
////                switch newMediaData {
////                case is JSQPhotoMediaItem:
////                    (newMediaData as! JSQPhotoMediaItem).image = newMediaAttachmentCopy as? UIImage
////                    self.collectionView!.reloadData()
////                case is JSQLocationMediaItem:
////                    (newMediaData as! JSQLocationMediaItem).setLocation(newMediaAttachmentCopy as? CLLocation, withCompletionHandler: {
////                        self.collectionView!.reloadData()
////                    })
////                case is JSQVideoMediaItem:
////                    (newMediaData as! JSQVideoMediaItem).fileURL = newMediaAttachmentCopy as? URL
////                    (newMediaData as! JSQVideoMediaItem).isReadyToPlay = true
////                    self.collectionView!.reloadData()
////                case is JSQAudioMediaItem:
////                    (newMediaData as! JSQAudioMediaItem).audioData = newMediaAttachmentCopy as? Data
////                    self.collectionView!.reloadData()
////                default:
////                    assertionFailure("Error: This Media type was not recognised")
////                }
////            }
////        }
////    }
//
//
//
//    // MARK: JSQMessagesViewController method overrides
//    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
//        /**
//         *  Sending a message. Your implementation of this method should do *at least* the following:
//         *
//         *  1. Play sound (optional)
//         *  2. Add new id<JSQMessageData> object to your data source
//         *  3. Call `finishSendingMessage`
//         */
//        self.newJobMessages(newMessage: text)
//
//        // changes made
////        let message = JSQMessage(senderId: senderID, senderDisplayName: senderDisplayName, date: date, text: text)
////        self.messages.append(message!)
//        self.finishSendingMessage(animated: true)
//    }
//
//    override func didPressAccessoryButton(_ sender: UIButton) {
////        self.inputToolbar.contentView!.textView!.resignFirstResponder()
////
////        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
////
////        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
////            /**
////             *  Create fake photo
////             */
////            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
////            self.addMedia(photoItem!)
////        }
////
////        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
////            /**
////             *  Add fake location
////             */
////            let locationItem = self.buildLocationItem()
////
////            self.addMedia(locationItem)
////        }
////
////        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
////            /**
////             *  Add fake video
////             */
////            let videoItem = self.buildVideoItem()
////
////            self.addMedia(videoItem)
////        }
////
////        let audioAction = UIAlertAction(title: "Send audio", style: .default) { (action) in
////            /**
////             *  Add fake audio
////             */
////            let audioItem = self.buildAudioItem()
////
////            self.addMedia(audioItem)
////        }
////
////        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
////
////        sheet.addAction(photoAction)
////        sheet.addAction(locationAction)
////        sheet.addAction(videoAction)
////        sheet.addAction(audioAction)
////        sheet.addAction(cancelAction)
////
////        self.present(sheet, animated: true, completion: nil)
//    }
//
//    func buildVideoItem() -> JSQVideoMediaItem {
//        let videoURL = URL(fileURLWithPath: "file://")
//
//        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
//
//        return videoItem!
//    }
//
//    func buildAudioItem() -> JSQAudioMediaItem {
//        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
//        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
//
//        let audioItem = JSQAudioMediaItem(data: audioData)
//
//        return audioItem
//    }
//
//    func buildLocationItem() -> JSQLocationMediaItem {
//        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
//
//        let locationItem = JSQLocationMediaItem()
//        locationItem.setLocation(ferryBuildingInSF) {
//            self.collectionView!.reloadData()
//        }
//
//        return locationItem
//    }
//
////    func addMedia(_ media:JSQMediaItem) {
////        let message = JSQMessage(senderId: senderID, displayName: self.senderDisplayNamee(), media: media)
////        self.messages.append(message!)
////
////        //Optional: play sent sound
////
////        self.finishSendingMessage(animated: true)
////    }
//
////    public func senderIdd() -> String {
////        return User.Wozniak.rawValue
////    }
//
//
//    private func addMessage(withId id: String, name: String, text: String) {
//        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
//            messages.append(message)
//        }
//    }
//
//    //MARK: JSQMessages CollectionView DataSource
//
//
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
//        return messages[indexPath.item]
//    }
//
//    // changes made
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        let message = messages[indexPath.item]
//
////        if message.senderId == MessageSourceType.Company.rawValue {
////            cell.textView?.textColor = UIColor.white
////
////        } else {
////            cell.textView?.textColor = UIColor.black
////
////        }
//
//        if message.senderId == MessageSourceType.Company.rawValue {
//            cell.textView?.textColor = UIColor.black
//
//            var selectedImage = String()
//            var name = String()
//
//            if let user = AppUser.getUser() {
//
//                for i in queryMessages {
//
//                    if i.senderID != user._id {
//                        selectedImage = i.profileImageURL as String
//                        name = i.displayName
//                    }
//                }
//            }
//
////            var newStr = selectedImage
////            newStr.remove(at: (newStr.startIndex))
////            let imageUrl = URLConfiguration.ServerUrl + newStr
////            cell.avatarImageView.sd_setImage(with: URL(string: imageUrl)!)
////            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
////            cell.avatarImageView.clipsToBounds = true
//
//            cell.messageBubbleTopLabel.text = name
//            cell.messageBubbleTopLabel.font = UIFont.boldSystemFont(ofSize: 16)
//            cell.messageBubbleTopLabel.textColor = UIColor.black
//            self.title = name
//
//
//        }
//        else
//        {
//            cell.textView?.textColor = UIColor.white
//
//            if let user = AppUser.getUser() {
//
////                var newStr = user.profileImageURL! as String
////                newStr.remove(at: (newStr.startIndex))
////                let imageUrl = URLConfiguration.ServerUrl + newStr
////                cell.avatarImageView.sd_setImage(with: URL(string: imageUrl)!)
////                cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
////                cell.avatarImageView.clipsToBounds = true
//
//                cell.messageBubbleTopLabel.text = user.displayName
//                cell.messageBubbleTopLabel.font = UIFont.boldSystemFont(ofSize: 16)
//                cell.messageBubbleTopLabel.textColor = UIColor.black
//            }
//        }
//
//
//        return cell
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
//
//        return messages[indexPath.item].senderId == MessageSourceType.Company.rawValue ? incomingBubble : outgoingBubble
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
//
//        return nil
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
//        /**
//         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
//         *  The other label text delegate methods should follow a similar pattern.
//         *
//         *  Show a timestamp for every 3rd message
//         */
////        if (indexPath.item % 3 == 0) {
////            let message = self.messages[indexPath.item]
////
////            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
////        }
//
//        return nil
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
//        let message = messages[indexPath.item]
//
//        // Displaying names above messages
//        //Mark: Removing Sender Display Name
//        /**
//         *  Example on showing or removing senderDisplayName based on user settings.
//         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
//         */
//        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
//            return nil
//        }
//
//        if message.senderId == MessageSourceType.Company.rawValue {
//            return nil
//        }
//
//        return NSAttributedString(string: message.senderDisplayName)
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
//        /**
//         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
//         */
//
//        /**
//         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
//         *  The other label height delegate methods should follow similarly
//         *
//         *  Show a timestamp for every 3rd message
//         */
////        if indexPath.item % 3 == 0 {
////            return kJSQMessagesCollectionViewCellLabelHeightDefault
////        }
//
//        return 0.0
//    }
//
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
//
//        /**
//         *  Example on showing or removing senderDisplayName based on user settings.
//         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
//         */
////        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
////            return 0.0
////        }
//
//        /**
//         *  iOS7-style sender name labels
//         */
//        let currentMessage = self.messages[indexPath.item]
//
//        if currentMessage.senderId == MessageSourceType.Company.rawValue || currentMessage.senderId == MessageSourceType.Driver.rawValue {
//            return 0.0
//        }
////
////        if indexPath.item - 1 > 0 {
////            let previousMessage = self.messages[indexPath.item - 1]
////            if previousMessage.senderId == currentMessage.senderId {
////                return 0.0
////            }
////        }
//
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }
//
//}
