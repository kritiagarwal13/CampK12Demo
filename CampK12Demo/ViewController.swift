//
//  ViewController.swift
//  CampK12Demo
//
//  Created by Kriti Agarwal on 10/11/18.
//  Copyright © 2018 Kriti Agarwal. All rights reserved.
//

import UIKit
import OpenTok

class ViewController: UIViewController {

    // Replace with your OpenTok API key
    var kApiKey = "46218572"
    // Replace with your generated session ID
    var kSessionId = "2_MX40NjIxODU3Mn5-MTU0MTgzNzY5OTUyOH45bGZJVm1JcHNId0NrRUpianZKd2p3azh-fg"
    // Replace with your generated token
    // Token for Publisher
//    var kToken = "T1==cGFydG5lcl9pZD00NjIxODU3MiZzaWc9ZDRjZDAwZWYxYmZkMGRlZjYyYzg0M2M3Mzc0NGI4NTYxM2U2N2UwYzpzZXNzaW9uX2lkPTJfTVg0ME5qSXhPRFUzTW41LU1UVTBNVGd6TnpZNU9UVXlPSDQ1YkdaSlZtMUpjSE5JZDBOclJVcGlhblpLZDJwM2F6aC1mZyZjcmVhdGVfdGltZT0xNTQxODM3NzM2Jm5vbmNlPTAuNzM1ODQ4NTUzNDA2MDA1MyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTQ0NDI5NzM0JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    // Token for subscriber
    var kToken = "T1==cGFydG5lcl9pZD00NjIxODU3MiZzaWc9Nzc3YjI5YTJkYWY2OTczZTA2ZTY1Njc3OGYzMGYxYjhlMzEzMmRkMjpzZXNzaW9uX2lkPTFfTVg0ME5qSXhPRFUzTW41LU1UVTBNVGcxTWpreU1qZzBPWDVvUlhVM2FIVmhlR28xVlVjMFRFWkdZelp6U1d4Q1ExcC1mZyZjcmVhdGVfdGltZT0xNTQxODUzMTgyJm5vbmNlPTAuMDk1NTI5MDAxNzI2MzgwMzUmcm9sZT1zdWJzY3JpYmVyJmV4cGlyZV90aW1lPTE1NDQ0NDUxODEmaW5pdGlhbF9sYXlvdXRfY2xhc3NfbGlzdD0="
    
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let url = URL(string: "https://camk12demo.herokuapp.com/session")
        let dataTask = session.dataTask(with: url!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil, let data = data else {
                print(error!)
                return
            }
            
            let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any]
            self.kApiKey = dict?["apiKey"] as? String ?? ""
            self.kSessionId = dict?["sessionId"] as? String ?? ""
            self.kToken = dict?["token"] as? String ?? ""
            self.connectToAnOpenTokSession()
        }
        dataTask.resume()
        session.finishTasksAndInvalidate()
    }

    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }

    }
    
    @objc(session:streamDestroyed:) func session(_ session: OTSession, streamDestroyed stream: OTStream) {
//        subscriber = OTSubscriber(stream: stream, delegate: self as OTSubscriberKitDelegate)
//        guard let subscriber = subscriber else {
//            return
//        }
//
//        var error: OTError?
//        session.subscribe(subscriber, error: &error)
//        guard error == nil else {
//            print(error!)
//            return
//        }
//
//        guard let subscriberView = subscriber.view else {
//            return
//        }
//        subscriberView.frame = UIScreen.main.bounds
//        view.insertSubview(subscriberView, at: 0)
    }

}

    // MARK: - OTSessionDelegate callbacks
    extension ViewController: OTSessionDelegate {
        func sessionDidConnect(_ session: OTSession) {
            print("The client connected to the OpenTok session.")
            
            let settings = OTPublisherSettings()
            settings.name = UIDevice.current.name
            guard let publisher = OTPublisher(delegate: self as OTPublisherKitDelegate, settings: settings) else {
                return
            }
            
            var error: OTError?
            session.publish(publisher, error: &error)
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let publisherView = publisher.view else {
                return
            }
            let screenBounds = UIScreen.main.bounds
            publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
            view.addSubview(publisherView)
        }
        
        func sessionDidDisconnect(_ session: OTSession) {
            print("The client disconnected from the OpenTok session.")
        }
        
        func session(_ session: OTSession, didFailWithError error: OTError) {
            print("The client failed to connect to the OpenTok session: \(error).")
        }
        
        func session(_ session: OTSession, streamCreated stream: OTStream) {
            print("A stream was created in the session.")
            
            subscriber = OTSubscriber(stream: stream, delegate: self)
            guard let subscriber = subscriber else {
                return
            }
            
            var error: OTError?
            session.subscribe(subscriber, error: &error)
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let subscriberView = subscriber.view else {
                return
            }
            subscriberView.frame = UIScreen.main.bounds
            view.insertSubview(subscriberView, at: 0)
        }
       
}

extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

extension ViewController: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}
