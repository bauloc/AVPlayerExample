//
//  PlayerView.swift
//  AVPlayerExample
//
//  Created by BAU LOC on 8/8/20.
//  Copyright © 2020 BAULOC. All rights reserved.
//

import UIKit
import AVFoundation

/// A simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
class PlayerView: FSeekingPlayer {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var borderWidth:CGFloat = 0
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 13, *) {
            let maskLayer = playerLayer.mask ?? CALayer()
            maskLayer.frame = playerLayer.bounds.insetBy(dx: 0, dy: 0)
            maskLayer.backgroundColor = UIColor.black.cgColor
            playerLayer.mask = maskLayer
        }
    }
}
