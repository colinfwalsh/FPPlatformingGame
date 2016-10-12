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
    
    var speedTimer: Timer!
    
    var airTimer: Timer!
    
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
    
    override func didMove(to view: SKView) {
        
        
        
        //Button setup-KC
        
        resetButton.position = CGPoint(x: frame.midX, y: frame.midY + 10)
        
        resetButton.size = CGSize(width: 260, height: 60)
        
        resetButton.name = "resetButton"
        
        self.addChild(resetButton)
        
        resetButton.isHidden = true
        
        
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        
        playButton.name = "playButton"
        
        playButton.zPosition = 0
        
        self.addChild(playButton)
        
//        (x: frame.minX + 50, frame.minY + 33)
        
        gravityButton.position = CGPoint(x: frame.minX + 50, y: frame.minY + 33)
        
        gravityButton.size = CGSize(width: 50, height: 50)
        
        gravityButton.name = "gravityButton"
        
        self.addChild(gravityButton)
        
        gravityButton.isHidden = false
        
//        (x: frame.minX + 120, frame.minY + 33)
        
        velocityButton.position = CGPoint(x: frame.minX + 120, y: frame.minY + 33)
        
        velocityButton.size = CGSize(width: 50, height: 50)
        
        velocityButton.name = "velocityButton"
        
        self.addChild(velocityButton)
        
        velocityButton.isHidden = false
        
//        CGRectGetMaxX(frame) - 50, CGRectGetMaxY(frame) - 40)
        
        certainDeathButton.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - 40)
        
        certainDeathButton.size = CGSize(width: 50, height: 50)
        
        certainDeathButton.name = "certainDeathButton"
        
        self.addChild(certainDeathButton)
        
        certainDeathButton.isHidden = true
        
//        (CGRectGetMaxX(frame) - 50, CGRectGetMinY(frame) + 33)
        
        hardResetButton.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 33)
        
        hardResetButton.size = CGSize(width: 50, height: 50)
        
        hardResetButton.name = "hardResetButton"
        
        self.addChild(hardResetButton)
        
        hardResetButton.isHidden = true
        
        
        //Label Setup-KC
        
//        CGRectGetMidX(frame), CGRectGetMidY(frame) + 40)
        
        resultsLabel.position = CGPoint(x: frame.midX, y: frame.midY + 40)
        resultsLabel.text = ""
        self.addChild(resultsLabel)
        resultsLabel.isHidden = true
        
        //highScore.position = CGPoint(x:130, y: 380)
        
//        (CGRectGetMinX(frame) + 120, CGRectGetMaxY(frame) - 40)
        
        highScore.position = CGPoint(x: frame.minX + 120, y: frame.maxY - 40)
        self.addChild(highScore)
        highScore.isHidden = false
        
        //longestAirTimeLabel.position = CGPoint(x:330, y: 380)
        
//        (CGRectGetMinX(frame) + 320, CGRectGetMaxY(frame) - 40)
        longestAirTimeLabel.position = CGPoint(x: frame.minX + 320, y: frame.maxY - 40)
        self.addChild(longestAirTimeLabel)
        longestAirTimeLabel.isHidden = false
        
//        (CGRectGetMidX(frame), CGRectGetMidY(frame) - 45)
        
        airTimeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 45)
        airTimeLabel.text = ""
        self.addChild(airTimeLabel)
        airTimeLabel.isHidden = true
        
        //effectLabel.position = CGPoint(x:580, y: 360)
//        (CGRectGetMinX(frame) + 520, CGRectGetMaxY(frame) - 40)
        
        effectLabel.position = CGPoint(x: frame.minX + 520, y: frame.maxY - 40)
        self.addChild(effectLabel)
        effectLabel.isHidden = true
        
        startPhysics()
        
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        man.physicsBody?.collisionBitMask = worldCategory
        
        if playButton.isHidden == true {
            moving.speed = 0
            
            self.removeAction(forKey: "flash")
            self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.run({
                self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            }),SKAction.wait(forDuration: TimeInterval(0.05)), SKAction.run({
                self.backgroundColor = self.skyColor
            }), SKAction.wait(forDuration: TimeInterval(0.05))]), count:4), SKAction.run({
                self.canRestart = true
            })]), withKey: "flash")
            
            man.removeAllActions()
            
            //Present reset after collision-KC
            
            resetButton.isHidden = false
            
            //Displays Distance-KC
            
            updateDistance()
            
            //Stop counting airtime-KC
            
            airTimer.invalidate()
            
            print ("collision")
            
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("At touch start \(xForceToApply), \(yForceToApply)")
        
        //listens for touch to make nodes as buttons work-KC
        
        let touch = touches.first! as UITouch
        
        let location = touch.location(in: self)
        
        let node = self.atPoint(location)
        
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
        
        speedTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(decrementRunningVelocity), userInfo: nil, repeats: true)
        
        animateGround(runningRate: groundVelocity)
        walkingMan(runningRate: runningVelocity)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Attempt to disable jump after reset-KC
        
        if isPlaying == true {
            
            //Dividing to have current velocity impact impulse force-KC
            
            xForceToApply /= runningVelocity * 5
            yForceToApply /= runningVelocity * 9
            
            man.physicsBody?.velocity = CGVector(dx: xVelocity, dy: yVelocity)
            
            print("\(xForceToApply), \(yForceToApply)")
            
            //Uses xForce and yForce properties as arguments-KC
            
            man.physicsBody?.applyImpulse(CGVector(dx: xForceToApply, dy: yForceToApply))
            
            
            if xVelocity == 0 {
            airTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementAirTime), userInfo: nil, repeats: true)
            airTimeLabel.isHidden = false
            }
        }
        
        //Stop Speeding up-KC
        
        speedTimer.invalidate()
        
        //Easter Egg
        
        if let nodeWithValue = buttonTrigger.name{
            
            print(nodeWithValue)
            
            print(touchLength)
            
            if nodeWithValue == "velocityButton" && touchLength >= 5 {
                
                certainDeathButton.isHidden = false
                
            }
        }
        
        
        if ((man.physicsBody?.collisionBitMask = worldCategory) != nil) {
            let anim = SKAction.animate(with: [SKTexture(imageNamed:"man6")], timePerFrame: 0.1)
            let run = SKAction.repeat(anim, count: 5)
            man.run(run)
        }
        
    }
    
    func walkingMan(runningRate: Double) {
        let anim = SKAction.animate(with: [SKTexture(imageNamed:"man1"), SKTexture(imageNamed:"man2"), SKTexture(imageNamed:"man3"), SKTexture(imageNamed:"man4")], timePerFrame: runningRate)
        let run = SKAction.repeatForever(anim)
        man.run(run)
    }
    
    func animateGround(runningRate: Double) {
        let moveGroundsprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(runningRate * Double(groundTexture.size().width / 2))) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundsprite, resetGroundSprite]))  //Takes both sequences and repeats them forever
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
            i += 1
        }
    }
    
    //Allows timer to adjust running and ground velocity based on held touch-KC
    
    func decrementRunningVelocity(){
        if runningVelocity > 0.15 {
            
            runningVelocity -= 0.05
            
            
            walkingMan(runningRate: runningVelocity)
            
            print("Run \(runningVelocity)")
            
            
        }
        
        if groundVelocity > 0.1 {
            
            groundVelocity -= 0.05
            animateGround(runningRate: groundVelocity)
            print("Ground \(groundVelocity)")
        }
        
        if groundVelocity == 0.05 {
            groundVelocity = 0.025
            animateGround(runningRate: groundVelocity)
            print("Ground \(groundVelocity)")
        }
        
        //Used for easter egg
        
        touchLength += 1
    }
    
    //Resets for new jump-KC
    
    func resetMegaPosition(){
        
        self.removeAllChildren()
        didMove(to: self.view!)
        runningVelocity = 0.4
        groundVelocity = 0.2
        xForceToApply = 50.0
        yForceToApply = 300.0
        xGravity = 0.0
        yGravity = -9.8
        self.canRestart = false
        isPlaying = false
        playButton.isHidden = false
        effectLabel.isHidden = false
        touchLength = 0.0
        
        if airtime > 0.0 {
            
            airTimer.invalidate()
            
        }
        airtime = 0.0
        print("After reset \(xForceToApply), \(yForceToApply)")
        
    }
    
    //Play button implementation-KC
    
    func allowGameToStart() {
        playButton.isHidden = true
        isPlaying = true
        gravityButton.isHidden = false
        velocityButton.isHidden = false
        hardResetButton.isHidden = false
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
        resultsLabel.isHidden = false
        
        if airtime > longestAirTime {
            longestAirTime = airtime
            longestAirTimeLabel.text = String.localizedStringWithFormat("Best Air: %.1f", longestAirTime)
        }
        
        
    }
    
    func incrementAirTime(){
        
        airtime += 0.1
        airTimeLabel.text = String.localizedStringWithFormat("Air Time: %.1f", airtime)
        
    }
    
    func adjustGravity(){
        
        effectLabel.isHidden = false
        
        let reverseGravity = CGVector(dx: 0.0, dy: 2.0)
        let noGravity = CGVector(dx: 0.0, dy: 0.0)
        let halfGravity = CGVector(dx: 0.0, dy: -4.9)
        let earthGravity = CGVector(dx: 0.0, dy: -9.8)
        
        
        let gravityArray = [reverseGravity, noGravity, halfGravity, earthGravity]
        
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
        
        hardResetButton.isHidden = false
        
    }
    
    func adjustVelocity(){
        
        effectLabel.isHidden = false
        
        if xVelocity == 0 {
            
            xVelocity = 600
            
            xForceToApply = 0
            yForceToApply = 0
            
            effectLabel.text = "Velocity!!"
            
        }else{
            
            xVelocity = 0
            
            effectLabel.text = ""
        }
        
        hardResetButton.isHidden = false
        
    }
    
    func applyCertainDeath() {
        
        self.physicsWorld.gravity = CGVector(dx: -5.0, dy: -9.8)
        
        hardResetButton.isHidden = false
        
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
        
        groundTexture.filteringMode = .nearest //No idea what this does - something with size?  Compatability?
        
        
        
        //Essentially creates the loop to repeat the ground action as long as the lessThanValue is true
        //What is the lessThanValue?  No idea - Going to try and add the megaman sprite here and see if it loops
        
        
        //Attatching the physics properties/methods to megaMan
        
        let moveGroundsprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: 0.0) //So this is just a formula for how fast the groundtexture moves accross the scene
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position - I think
        
        let makeGround = SKAction.repeat(SKAction.sequence([moveGroundsprite, resetGroundSprite]), count: 0)  //Takes both sequences and repeats them forever
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width / 2)
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.run(makeGround)
            moving.addChild(sprite)
            i += 1
        }
        
        man = SKSpriteNode(texture: SKTexture(imageNamed: "man5"))
        
        man.zPosition = 1
        man.setScale(0.8)
        man.position = CGPoint(x: self.frame.size.width * 0.15, y: groundTexture.size().height + 0.5)
        
        
        man.physicsBody = SKPhysicsBody(circleOfRadius: man.size.height / 2.0)
        man.physicsBody?.isDynamic = true
        man.physicsBody?.allowsRotation = false
        
        
        man.physicsBody?.categoryBitMask = manCategory
        man.physicsBody?.collisionBitMask = worldCategory
        man.physicsBody?.contactTestBitMask = worldCategory
        
        self.addChild(man)
        
        //Creating the ground
        let ground = SKNode()
        
        ground.position = CGPoint(x: 0, y: groundTexture.size().height / 16)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width * 4, height: groundTexture.size().height))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        //Storing initial position for distance-KC
        
        manInitialPosition = man.position
    }
    

}





