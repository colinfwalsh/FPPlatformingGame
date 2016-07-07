//
//  GameScene.swift
//  FPPlatformingGame
//
//  Created by Colin Walsh on 7/6/16.
//  Copyright (c) 2016 Colin Walsh. All rights reserved.
//

import SpriteKit

var megaMan : SKSpriteNode!
var megaManWalking : [SKTexture]!



class GameScene: SKScene {
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = (UIColor.grayColor())
        
        let manAnimatedAtlas = SKTextureAtlas(named: "man")
        var walkFrames = [SKTexture]()
        
        let numImages = manAnimatedAtlas.textureNames.count
        
        
        for var i=1; i<=numImages; i += 1 {
            
            let manTextureName = "man\(i)"
            walkFrames.append(manAnimatedAtlas.textureNamed(manTextureName))
            
            
        }
        
        megaManWalking = walkFrames
        
        let firstFrame = megaManWalking[0]
        megaMan = SKSpriteNode(texture: firstFrame)
        megaMan.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        addChild(megaMan)
        
        walkingMan()
        
    }
    

    
    func walkingMan() {
        //This is our general runAction method to make our bear walk.
        megaMan.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(megaManWalking,
                timePerFrame: 0.15,
                resize: false,
                restore: true)),
                          withKey:"walkingInPlaceMan")
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
