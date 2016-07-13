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
    
    let groundTexture = SKTexture(imageNamed: "land")
    
    //Status Properties-KC
    
    var canRestart : Bool = false
    
    var isTouched = false
    
    var gravityCounter = 0
    
    var touchLength = 0.0
    
    //Timers-KC
    
    var speedTimer: NSTimer!
    
    var airTimer: NSTimer!
    
    //Forces-KC
    
    var runningVelocity : Double = 0.4
    
    var groundVelocity: Double = 0.2
    
    var xForceToApply = 50.0
    
    var yForceToApply = 300.0
    
    var xGravity = 0.0
    
    var yGravity = -9.8
    
    var xVelocity = 0.0
    
    var yVelocity = 0.0
    
    //Buttons-KC
    
    let playButton = SKSpriteNode(imageNamed:"flatironmanlogo")
    
    let resetButton = SKSpriteNode(imageNamed:"restart")
    
    let gravityButton = SKSpriteNode(imageNamed:"grav_button")
    
    let velocityButton = SKSpriteNode(imageNamed:"velocity_button")
    
    let certainDeathButton = SKSpriteNode(imageNamed:"skull_button")
    
    let hardResetButton = SKSpriteNode(imageNamed:"small_reset")
    
    var isPlaying = false
    
    //Shares touch to "buttons"-KC
    
    var buttonTrigger: SKNode!
    
    var resultsLabel = SKLabelNode()
    
    var highScore = SKLabelNode()
    
    var highScoreDistance = 0
    
    //Used to calculate distance traveled-KC
    var manInitialPosition: CGPoint!
    
    //Air Time implementation
    var airtime = 0.0
    
    var airTimeLabel = SKLabelNode()
    
    var longestAirTimeLabel = SKLabelNode()
    
    var longestAirTime = 0.0
    
    var effectLabel = SKLabelNode()
    
    
    //No idea what these do, got it from the Flappy Bird source code
    let manCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 0
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMoveToView(view: SKView) {
        
        
        
        //Button setup-KC
        
        resetButton.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) + 10)
        
        resetButton.size = CGSizeMake(260, 60)
        
        resetButton.name = "resetButton"
        
        self.addChild(resetButton)
        
        resetButton.hidden = true
        
        
        playButton.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        
        playButton.name = "playButton"
        
        playButton.zPosition = 0
        
        self.addChild(playButton)
        
        
        gravityButton.position = CGPointMake(CGRectGetMinX(frame) + 50, CGRectGetMinY(frame) + 33)
        
        gravityButton.size = CGSizeMake(50, 50)
        
        gravityButton.name = "gravityButton"
        
        self.addChild(gravityButton)
        
        gravityButton.hidden = false
        
        
        velocityButton.position = CGPointMake(CGRectGetMinX(frame) + 120, CGRectGetMinY(frame) + 33)
        
        velocityButton.size = CGSizeMake(50, 50)
        
        velocityButton.name = "velocityButton"
        
        self.addChild(velocityButton)
        
        velocityButton.hidden = false
        
        
        certainDeathButton.position = CGPointMake(CGRectGetMaxX(frame) - 50, CGRectGetMaxY(frame) - 40)
        
        certainDeathButton.size = CGSizeMake(50, 50)
        
        certainDeathButton.name = "certainDeathButton"
        
        self.addChild(certainDeathButton)
        
        certainDeathButton.hidden = true
        
        
        hardResetButton.position = CGPointMake(CGRectGetMaxX(frame) - 50, CGRectGetMinY(frame) + 33)
        
        hardResetButton.size = CGSizeMake(50, 50)
        
        hardResetButton.name = "hardResetButton"
        
        self.addChild(hardResetButton)
        
        hardResetButton.hidden = true
        
        
        //Label Setup-KC
        
        resultsLabel.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) + 40)
        resultsLabel.text = ""
        self.addChild(resultsLabel)
        resultsLabel.hidden = true
        
        //highScore.position = CGPoint(x:130, y: 380)
        highScore.position = CGPointMake(CGRectGetMinX(frame) + 120, CGRectGetMaxY(frame) - 40)
        self.addChild(highScore)
        highScore.hidden = false
        
        //longestAirTimeLabel.position = CGPoint(x:330, y: 380)
        longestAirTimeLabel.position = CGPointMake(CGRectGetMinX(frame) + 320, CGRectGetMaxY(frame) - 40)
        self.addChild(longestAirTimeLabel)
        longestAirTimeLabel.hidden = false
        
        
        airTimeLabel.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - 45)
        airTimeLabel.text = ""
        self.addChild(airTimeLabel)
        airTimeLabel.hidden = true
        
        //effectLabel.position = CGPoint(x:580, y: 360)
        effectLabel.position = CGPointMake(CGRectGetMinX(frame) + 520, CGRectGetMaxY(frame) - 40)
        self.addChild(effectLabel)
        effectLabel.hidden = true
        
        startPhysics()
        
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        man.physicsBody?.collisionBitMask = worldCategory
        
        if playButton.hidden == true {
            moving.speed = 0
            
            self.removeActionForKey("flash")
            self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
                self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
                self.backgroundColor = self.skyColor
            }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
                self.canRestart = true
            })]), withKey: "flash")
            
            man.removeAllActions()
            
            //Present reset after collision-KC
            
            resetButton.hidden = false
            
            //Displays Distance-KC
            
            updateDistance()
            
            //Stop counting airtime-KC
            
            airTimer.invalidate()
            
            print ("collision")
            
        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print("At touch start \(xForceToApply), \(yForceToApply)")
        
        //listens for touch to make nodes as buttons work-KC
        
        let touch = touches.first! as UITouch
        
        let location = touch.locationInNode(self)
        
        let node = self.nodeAtPoint(location)
        
        //Pushes to property-KC
        
        buttonTrigger = node
        
        
        //Trigger button implementations based on tap-KC
        
        if let nodeWithValue = buttonTrigger.name{
            
            print(nodeWithValue)
            
            
            if nodeWithValue == "resetButton" {
                resetMegaPosition()
            }
            
            if nodeWithValue == "playButton" {
                allowGameToStart()
            }
            
            if nodeWithValue == "velocityButton" {
                
                adjustVelocity()
                
            }
            
            if nodeWithValue == "gravityButton" {
                
                adjustGravity()
                
            }
            
            if nodeWithValue == "certainDeathButton"{
                
                applyCertainDeath()
                
            }
            
            if nodeWithValue == "hardResetButton"{
                
                resetMegaPosition()
                
            }
        }
        
        //playButton.removeFromParent()
        
        
        //Timer fires for as long as touch is held in order to decrement velocity-KC
        
        speedTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(decrementRunningVelocity), userInfo: nil, repeats: true)
        
        animateGround(groundVelocity)
        walkingMan(runningVelocity)
        
        
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //Attempt to disable jump after reset-KC
        
        if isPlaying == true {
            
            //Dividing to have current velocity impact impulse force-KC
            
            xForceToApply /= runningVelocity * 5
            yForceToApply /= runningVelocity * 9
            
            man.physicsBody?.velocity = CGVector(dx: xVelocity, dy: yVelocity)
            
            print("\(xForceToApply), \(yForceToApply)")
            
            //Uses xForce and yForce properties as arguments-KC
            
            man.physicsBody?.applyImpulse(CGVector(dx: xForceToApply, dy: yForceToApply))
            
            
            
            airTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(incrementAirTime), userInfo: nil, repeats: true)
            airTimeLabel.hidden = false
        }
        //Stop Speeding up-KC
        
        speedTimer.invalidate()
        
        //Easter Egg
        
        
        
        if let nodeWithValue = buttonTrigger.name{
            
            print(nodeWithValue)
            
            print(touchLength)
            
            if nodeWithValue == "velocityButton" && touchLength >= 5 {
                
                certainDeathButton.hidden = false
                
            }
        }
        
        
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
    
    func animateGround(runningRate: Double) {
        let moveGroundsprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(runningRate * Double(groundTexture.size().width / 2))) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundsprite, resetGroundSprite]))  //Takes both sequences and repeats them forever
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
            i += 1
        }
    }
    
    //Allows timer to adjust running and ground velocity based on held touch-KC
    
    func decrementRunningVelocity(){
        if runningVelocity > 0.15 {
            
            runningVelocity -= 0.05
            
            
            walkingMan(runningVelocity)
            
            print("Run \(runningVelocity)")
            
            
        }
        
        if groundVelocity > 0.1 {
            
            groundVelocity -= 0.05
            animateGround(groundVelocity)
            print("Ground \(groundVelocity)")
        }
        
        if groundVelocity == 0.05 {
            groundVelocity = 0.025
            animateGround(groundVelocity)
            print("Ground \(groundVelocity)")
        }
        
        //Used for easter egg
        
        touchLength += 1
    }
    
    //Resets for new jump-KC
    
    func resetMegaPosition(){
        
        self.removeAllChildren()
        didMoveToView(self.view!)
        //certainDeathButton.hidden = false
        runningVelocity = 0.4
        groundVelocity = 0.2
        xForceToApply = 50.0
        yForceToApply = 300.0
        xGravity = 0.0
        yGravity = -9.8
        self.canRestart = false
        isPlaying = false
        playButton.hidden = false
        effectLabel.hidden = false
        touchLength = 0.0
        
        if airtime > 0.0 {
            
            airTimer.invalidate()
            
        }
        airtime = 0.0
        print("After reset \(xForceToApply), \(yForceToApply)")
        
    }
    
    //Play button implementation-KC
    
    func allowGameToStart() {
        playButton.hidden = true
        isPlaying = true
        gravityButton.hidden = false
        velocityButton.hidden = false
        hardResetButton.hidden = false
    }
    
    func updateDistance() {
        let manFinalPosition = man.position
        
        
        //Using 5 to convert to "feet"-KC
        
        let manDistance = (manFinalPosition.x - manInitialPosition.x) / 5
        
        let manDistanceInFeet = Int(manDistance)
        
        if manDistanceInFeet > highScoreDistance {
            highScoreDistance = manDistanceInFeet
            highScore.text = "High Score: \(highScoreDistance)"
        }
        
        resultsLabel.text = "You jumped \(manDistanceInFeet)ft!"
        resultsLabel.hidden = false
        
        if airtime > longestAirTime {
            longestAirTime = airtime
            longestAirTimeLabel.text = "Best Air: \(longestAirTime)"
        }
        
        
    }
    
    func incrementAirTime(){
        
        airtime += 0.1
        airTimeLabel.text = "Air Time: \(airtime)"
        
    }
    
    func adjustGravity(){
        
        effectLabel.hidden = false
        
        let reverseGravity = CGVector(dx: 0.0, dy: 2.0)
        let noGravity = CGVector(dx: 0.0, dy: 0.0)
        let halfGravity = CGVector(dx: 0.0, dy: -4.9)
        let earthGravity = CGVector(dx: 0.0, dy: -9.8)
        
        
        let gravityArray = [reverseGravity, noGravity, halfGravity,earthGravity]
        
        if gravityCounter == 4 {
            
            gravityCounter = 0
            
        }
        
        if gravityCounter == 3 {
            
            effectLabel.text = ""
            
            
        } else {
            
            effectLabel.text = "Gravity: \(gravityCounter + 1)"
            
        }
        
        self.physicsWorld.gravity = gravityArray[gravityCounter]
        
        gravityCounter += 1
        
        hardResetButton.hidden = false
        
    }
    
    func adjustVelocity(){
        
        effectLabel.hidden = false
        
        if xVelocity == 0 {
            
            xVelocity = 600
            
            xForceToApply = 0
            yForceToApply = 0
            
            effectLabel.text = "Velocity!!"
            
        }else{
            
            xVelocity = 0
            
            effectLabel.text = ""
        }
        
        hardResetButton.hidden = false
        
    }
    
    func applyCertainDeath() {
        
        self.physicsWorld.gravity = CGVector(dx: -5.0, dy: -9.8)
        
        hardResetButton.hidden = false
        
    }
    
    
    func startPhysics(){
        
        //Setup physics - What is contact delegate?  Objects in the scene?
        self.physicsWorld.gravity = CGVector(dx: xGravity, dy: yGravity)
        self.physicsWorld.contactDelegate = self
        
        //Color for the sky, essentially background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0) //Alpha is what again?
        self.backgroundColor = skyColor //backgroundColor is an inherent property on GameScene
        
        moving = SKNode() //Initializes moving with a default value
        self.addChild(moving) //Adds a child node to the end of the reciever's list of child nodes?  That's the description - but what exactly does that mean?  Seems as if it adds the object into the scene to be displayed
        
        moving.zPosition = -1
        
        groundTexture.filteringMode = .Nearest //No idea what this does - something with size?  Compatability?
        
        
        
        //Essentially creates the loop to repeat the ground action as long as the lessThanValue is true
        //What is the lessThanValue?  No idea - Going to try and add the megaman sprite here and see if it loops
        
        
        //Attatching the physics properties/methods to megaMan
        
        let moveGroundsprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: 0.0) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let makeGround = SKAction.repeatAction(SKAction.sequence([moveGroundsprite, resetGroundSprite]), count: 0)  //Takes both sequences and repeats them forever
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.runAction(makeGround)
            moving.addChild(sprite)
            i += 1
        }
        
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
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width * 4, height: groundTexture.size().height))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        //Storing initial position for distance-KC
        
        manInitialPosition = man.position
    }
    
}





