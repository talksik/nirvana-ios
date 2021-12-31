//
//  AgoraViewController.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/28/21.
//

import Foundation
import AgoraRtcKit

class AgoraViewController: UIViewController {
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAgoraEngine()
        joinChannel()
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: agoraDelegate)
    }
    
    func joinChannel() {
        agoraKit?.joinChannel(byToken: "006c8dfd65deb5c4741bd564085627139d0IABNfXkzm8r9a6sFHwJaWORj6MMdAbbTDypvdgmCjbw2JKHYMoUAAAAAEADQ943gkE7NYQEAAQCQTs1h", channelId: "TestChannel", info: nil, uid: 0, joinSuccess: {(channel, uid, elapsed) in})
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
    }
    
    func destroyInstance() {
        AgoraRtcEngineKit.destroy()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        leaveChannel()
        destroyInstance()
    }
}
