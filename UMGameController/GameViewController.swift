//
//  GameViewController.swift
//  UMGameController
//
//  Created by fOrest on 6/13/16.
//  Copyright (c) 2016 fOrest. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var gameScene = GameScene.init(fileNamed:"GameScene")
    
    var menuScene = MenuScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = gameScene {
            
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            //scene.scaleMode = .aspectFit
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
            
            menuScene.scaleMode = scene.scaleMode
            menuScene.size = scene.size
        }
    }
    
    func showMenuScene(_ transiton: SKTransition?) {
        
        let skView = self.view as! SKView
        
        if skView.scene == self.menuScene {
            return
        }
        if transiton == nil {
            
            skView.presentScene(self.menuScene)
        } else {
            
            skView.presentScene(self.menuScene, transition: transiton!)
        }
        
    }
    
    func showGameScene(_ transiton: SKTransition?) {
        
        let skView = self.view as! SKView
        
        if skView.scene == self.gameScene {
            return
        }
        
        skView.scene!.shouldEnableEffects = true
        skView.scene!.shouldRasterize = true
        
        self.menuScene.setBackground(SKSpriteNode(texture: skView.texture(from: skView.scene!)))
        
        skView.scene!.shouldRasterize = false
        skView.scene!.shouldEnableEffects = false
        
        if transiton == nil {
            
            skView.presentScene(self.gameScene)
        } else {
            
            skView.presentScene(self.gameScene!, transition: transiton!)
        }
        // added in xcode 8 to avoid an not refreshing bug
        self.gameScene!.backgroundColor = self.gameScene!.backgroundColor
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        
//        self.becomeFirstResponder()
//        super.viewDidAppear(animated)
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        
//        self.resignFirstResponder()
//        super.viewDidDisappear(animated)
//    }
    
    
    override var canBecomeFirstResponder : Bool {
        return true
    }


    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
