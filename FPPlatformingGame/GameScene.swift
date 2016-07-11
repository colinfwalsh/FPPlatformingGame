//
//  GameScene.swift
//  FPPlatformingGame
//
//  Created by Colin Walsh on 7/6/16.
//  Copyright (c) 2016 Colin Walsh. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var man: SKSpriteNode!
    
    var manRunning: SKAction!
    
    var skyColor: SKColor!
    
    var moving: SKNode!
    
    var distanceTraveled: CGFloat!
    
    let playButton = SKSpriteNode(imageNamed:"play")
    
    let groundTexture = SKTexture(imageNamed: "land")
    
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    
    var runningVelocity : Double = 0.5
    
    var canRestart : Bool = false
    
    var isTouched = false
    
    
    
    
    
    //No idea what these do, got it from the Flappy Bird source code
    let manCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 0
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMoveToView(view: SKView) {
        playButton.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        self.addChild(playButton)
        
        
        
        //Setup physics - What is contact delegate?  Objects in the scene?
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
        
        //Color for the sky, essentially background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0) //Alpha is what again?
        self.backgroundColor = skyColor //backgroundColor is an inherent property on GameScene
        
        moving = SKNode() //Initializes moving with a default value
        self.addChild(moving) //Adds a child node to the end of the reciever's list of child nodes?  That's the description - but what exactly does that mean?  Seems as if it adds the object into the scene to be displayed
        
        groundTexture.filteringMode = .Nearest //No idea what this does - something with size?  Compatability?
        
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        
        self.isTouched = true
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.runAction(animateGroundStill())
            moving.addChild(sprite)
            i += 1
        }
        
        
        //Essentially creates the loop to repeat the ground action as long as the lessThanValue is true
        //What is the lessThanValue?  No idea - Going to try and add the megaman sprite here and see if it loops
        
        
        //Attatching the physics properties/methods to megaMan
        man = SKSpriteNode(texture: SKTexture(imageNamed: "man5"))
        
        man.zPosition = 1
        man.setScale(0.8)
        man.position = CGPoint(x: self.frame.size.width * 0.15, y: groundTexture.size().height + 0.5)
        
        
        man.physicsBody = SKPhysicsBody(circleOfRadius: man.size.height / 2.0)
        man.physicsBody?.dynamic = true
        man.physicsBody?.allowsRotation = false
        
        
        man.physicsBody?.categoryBitMask = manCategory
        man.physicsBody?.collisionBitMask = worldCategory
        man.physicsBody?.contactTestBitMask = worldCategory
        
        self.addChild(man)
        
        //Creating the ground, for contact I guess?
        let ground = SKNode()
        
        ground.position = CGPoint(x: 0, y: groundTexture.size().height / 16)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: groundTexture.size().height))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var hasPlayButton = false
        
        for child in self.children {
            if child === playButton {
                hasPlayButton = true
                break
            }
            else {
                hasPlayButton = false}
                
        }

         man.physicsBody?.collisionBitMask = worldCategory
        
            if hasPlayButton == false {
            moving.speed = 0
        
            self.removeActionForKey("flash")
            self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
                self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
                self.backgroundColor = self.skyColor
            }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
                self.canRestart = true
            })]), withKey: "flash")
        
                }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        playButton.removeFromParent()
        
       // self.isTouched = true
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.runAction(animateGroundForever())
            moving.addChild(sprite)
            i += 1
        }
        
        walkingMan(runningVelocity)
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        man.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        man.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
        
        
        if ((man.physicsBody?.collisionBitMask = worldCategory) != nil) {
            let anim = SKAction.animateWithTextures([SKTexture(imageNamed:"man6")], timePerFrame: 0.1)
            let run = SKAction.repeatAction(anim, count: 5)
            man.runAction(run)
        }
        
    }
    
    func walkingMan(runningRate: Double) {
        let anim = SKAction.animateWithTextures([SKTexture(imageNamed:"man1"), SKTexture(imageNamed:"man2"), SKTexture(imageNamed:"man3"), SKTexture(imageNamed:"man4")], timePerFrame: runningRate)
        let run = SKAction.repeatActionForever(anim)
        man.runAction(run)
    }
    
    func animateGroundStill() -> SKAction{
        
        let moveGroundsprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(runningVelocity * Double(groundTexture.size().width / 2))) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let moveGroundSpriteAbit = SKAction.repeatAction(SKAction.sequence([moveGroundsprite, resetGroundSprite]), count: 0)
        return moveGroundSpriteAbit
    }
    
    func animateGroundForever() -> SKAction{
        let moveGroundsprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(runningVelocity * Double(groundTexture.size().width / 2))) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundsprite, resetGroundSprite]))  //Takes both sequences and repeats them forever
        return moveGroundSpritesForever
    }
}





