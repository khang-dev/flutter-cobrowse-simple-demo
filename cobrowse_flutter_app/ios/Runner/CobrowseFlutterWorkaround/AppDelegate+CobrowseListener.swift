//
//  AppDelegate+CobrowseListener.swift
//  Runner
//
//  Created by Khang Nguyen on 10/05/2022.
//

import Foundation


import Foundation
import UIKit
import Flutter
import CobrowseIO


enum ChannelName {
    static let remoteActionChannel = "Workaround.Cobrowse.RemoteAction"
}

enum ChannelStreamName {
    static let cobrowseEventStream = "cobrowseEventStream"
}

enum CobrowseEventType {
    static let remoteControl = "remoteControl"
    static let sessionUpdate = "sessionUpdate"
}

enum CobrowseTouchEvent {
    static let touchBegan = "touchBegan"
    static let touchMoved = "touchMoved"
    static let touchEnded = "touchEnded"
}

enum CobrowseSessionEvent {
    static let didStart = "didStart"
    static let didEnd = "didEnd"
}

extension AppDelegate : FlutterStreamHandler, CobrowseIODelegate {
    
    func initCobrowse(_ flutterBinaryMessenger: FlutterBinaryMessenger) {
        let remoteActionEventChannel = FlutterEventChannel(name: ChannelName.remoteActionChannel,
                                                           binaryMessenger: self.rootViewController.binaryMessenger)
        remoteActionEventChannel.setStreamHandler(self)
        CobrowseIO.instance().delegate = self
    }
    
    func cobrowseSessionDidUpdate(_ session: CBIOSession) {
        self.addCobrowseTouchListenerViewIfNeeded()
        if (session.state() == "active") {
            self.updateSessionEventToFlutter(sessionEvent: CobrowseSessionEvent.didStart)
        }
    }
    
    func cobrowseSessionDidEnd(_ session: CBIOSession) {
        self.removeCobrowseTouchListenerView()
        self.updateSessionEventToFlutter(sessionEvent: CobrowseSessionEvent.didEnd)
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cobrowseEventSink = nil
        return nil
    }
    
    func removeCobrowseTouchListenerView() {
        guard let listenerView = currentTouchListenerView else {
            return
        }
        DispatchQueue.main.async() {
            listenerView.removeFromSuperview();
            self.currentTouchListenerView = nil
        }
    }
    
    func addCobrowseTouchListenerViewIfNeeded() {
        if (self.currentTouchListenerView != nil) {
            return
        }
        
        self.currentTouchListenerView = CobrowseTouchListenerUIView()
        self.currentTouchListenerView!.backgroundColor = .clear
        self.currentTouchListenerView!.frame = CGRect(x:0, y: 0, width: screenWidth, height: screenHeight)
        self.currentTouchListenerView!.delegate = self
        
        self.rootViewController.view.addSubview(self.currentTouchListenerView!)
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        cobrowseEventSink = eventSink
        
        return nil
    }
    
    private func updateSessionEventToFlutter(sessionEvent: String) {
        guard let eventSink = cobrowseEventSink else {
            return
        }
        let jsonResult: NSMutableDictionary = NSMutableDictionary()
        
        jsonResult.setValue(sessionEvent, forKey: "event")
        jsonResult.setValue(CobrowseEventType.sessionUpdate, forKey: "eventType")
        
        eventSink(jsonResult)
    }
    
    private func updateTouchEventToFlutter(point: CGPoint, touchEventType: String) {
        guard let eventSink = cobrowseEventSink else {
            return
        }
        let jsonResult: NSMutableDictionary = NSMutableDictionary()
        
        jsonResult.setValue(point.x, forKey: "x")
        jsonResult.setValue(point.y, forKey: "y")
        jsonResult.setValue(touchEventType, forKey: "event")
        jsonResult.setValue(CobrowseEventType.remoteControl, forKey: "eventType")
        
        eventSink(jsonResult)
    }
    
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // Root View Controller.
    public var rootViewController: FlutterViewController {
        let controller : FlutterViewController = window!.rootViewController as! FlutterViewController
        
        return controller
    }
}


extension AppDelegate : CobrowseTouchListenerUIViewDelegate {
    func getTouchLocation(_ touch: CBIOTouch) ->  CGPoint {
        let rootView = self.rootViewController.view
        if (rootView == nil) {
            return CGPoint(x: 0, y: 0)
        }
        return  touch.position()
    }
    
    
    func onTouchBegan(touch: CBIOTouch) {
        let position = getTouchLocation(touch)
        updateTouchEventToFlutter(point: position, touchEventType: CobrowseTouchEvent.touchBegan)
    }
    
    func onTouchMoved(touch: CBIOTouch) {
        let position = getTouchLocation(touch)
        updateTouchEventToFlutter(point: position, touchEventType: CobrowseTouchEvent.touchMoved)
    }
    
    func onTouchCancelled(touch: CBIOTouch) {
        let position = getTouchLocation(touch)
        updateTouchEventToFlutter(point: position, touchEventType: CobrowseTouchEvent.touchEnded)
    }
    
    func onTouchEnded(touch: CBIOTouch) {
        let position = getTouchLocation(touch)
        updateTouchEventToFlutter(point: position, touchEventType: CobrowseTouchEvent.touchEnded)
    }
}

protocol CobrowseTouchListenerUIViewDelegate {
    func onTouchBegan(touch : CBIOTouch)
    func onTouchMoved(touch : CBIOTouch)
    func onTouchCancelled(touch : CBIOTouch)
    func onTouchEnded(touch : CBIOTouch)
}

class CobrowseTouchListenerUIView: UIView, CBIOResponder {
    var delegate: CobrowseTouchListenerUIViewDelegate?
    
    func cobrowseTouchesBegan(_ touches: Set<CBIOTouch>, with event: CBIOTouchEvent) {
        if let touch = touches.first {
            delegate?.onTouchBegan(touch: touch)
        }
    }
    
    func cobrowseTouchesMoved(_ touches: Set<CBIOTouch>, with event: CBIOTouchEvent) {
        
        if let touch = touches.first {
            delegate?.onTouchMoved(touch: touch)
        }
    }
    
    func cobrowseTouchesEnded(_ touches: Set<CBIOTouch>, with event: CBIOTouchEvent) {
        if let touch = touches.first {
            delegate?.onTouchCancelled(touch: touch)
        }
    }
    
    func cobrowseTouchesCancelled(_ touches: Set<CBIOTouch>, with event: CBIOTouchEvent) {
        if let touch = touches.first {
            delegate?.onTouchCancelled(touch: touch)
        }
    }
    
    func cobrowseKeyDown(_ event: CBIOKeyPress) {
    }
}
