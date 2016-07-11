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
    //var ground: SKSpriteNode!
    var skyColor: SKColor!
    var moving: SKNode!
    
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    
    var runningVelocity : CGFloat = 0.0
    
    var canRestart : Bool = false
    
    
    
    //No idea what these do, got it from the Flappy Bird source code
    let manCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 0
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMoveToView(view: SKView) {
        
        //Setup physics - What is contact delegate?  Objects in the scene?
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
        
        //Color for the sky, essentially background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0) //Alpha is what again?
        self.backgroundColor = skyColor //backgroundColor is an inherent property on GameScene
        
        moving = SKNode() //Initializes moving with a default value
        self.addChild(moving) //Adds a child node to the end of the reciever's list of child nodes?  That's the description - but what exactly does that mean?  Seems as if it adds the object into the scene to be displayed
        
        let groundTexture = SKTexture(imageNamed: "land") //Assigns a variable titled groundTexture to an SKTexture called Land - creates the ground texture
        groundTexture.filteringMode = .Nearest //No idea what this does - something with size?  Compatability?
        
        let moveGroundsprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.002 * groundTexture.size().width * 2.0)) //Moves the ground sprite over, towards the left - Why does it multiply by 2.0?  And the .02 * groundTexture.size().width * 2.0?
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0) //Creates a new sprite at the old sprites position
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundsprite, resetGroundSprite]))  //Takes both sequences and repeats them forever
        
        var i = CGFloat(0.0)
        
        let lessThanValue = 2.0 + self.frame.size.width / (groundTexture.size().width)
        
        //Essentially creates the loop to repeat the ground action as long as the lessThanValue is true
        //What is the lessThanValue?  No idea - Going to try and add the megaman sprite here and see if it loops
        
        
        while i < lessThanValue {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4) //Creates a sprite for the ground the width of the sprite picture, with the height of the picture divided by 2
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
            i += 1
        }
        
        
        //So far, with the build above, the ground will load indefinitely, looping through the ground animations
        
        //Setting up the megaman sprite
        let manTexture1 = SKTexture(imageNamed: "man1")
        manTexture1.filteringMode = .Nearest //Seems as if this is best practice for loading any texture
        let manTexture2 = SKTexture(imageNamed: "man2")
        
        
        let anim = SKAction.animateWithTextures([manTexture1, manTexture2], timePerFrame: 0.1)  //Creates and animation array with the above named textures
        let run = SKAction.repeatActionForever(anim) //Creates an action to repeat forever, as long as the conditions are met
        
        
        man = SKSpriteNode(texture: manTexture1)
        man.setScale(0.8)
        man.position = CGPoint(x: self.frame.size.width * 0.15, y: groundTexture.size().height + 0.5)
        man.runAction(run)
        
        man.physicsBody = SKPhysicsBody(circleOfRadius: man.size.height / 2.0)
        man.physicsBody?.dynamic = true
        man.physicsBody?.allowsRotation = false
        
        
        man.physicsBody?.categoryBitMask = manCategory
        man.physicsBody?.collisionBitMask = worldCategory
        man.physicsBody?.contactTestBitMask = worldCategory
        
        self.addChild(man)
        
        //Code from here to above, still no megaman sprite, maybe he needs to be rendered somehow?
        
        
        //Creating the ground, for contact I guess?
        let ground = SKNode()
        
        ground.position = CGPoint(x: 0, y: groundTexture.size().height / 16)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: groundTexture.size().height))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        //Same thing, just ground, no megaman, might be a fault with the code
        
        
        
        
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        //        if moving.speed > 0 {
        //            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
        //                // Bird has contact with score entity
        //                score += 1
        //                scoreLabelNode.text = String(score)
        //
        //                // Add a little visual feedback for the score increment
        //                scoreLabelNode.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
        //            } else {
        
        // moving.speed = 0
        
        man.physicsBody?.collisionBitMask = worldCategory
        //man.runAction(  SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(man.position.y) * 0.01, duration:1), completion:{self.man.speed = 0 })
        
        
        // Flash background if contact is detected
        self.removeActionForKey("flash")
        self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
            self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
            self.backgroundColor = self.skyColor
        }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
            self.canRestart = true
        })]), withKey: "flash")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        man.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        man.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
}


//         IMPLEMENTATION OF THE SPRITE - DOESNT COMPILE AS OF YET
//        var player: Player
//
//        override init(size: CGSize) {
//            self.player = Player(imageName: "man1")
//            super.init(size: size)
//
//        }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//
//
//    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        backgroundColor = (UIColor.grayColor())
//
//
//        player.animatePlayerSprite()
//
//        megaManWalking = player.walkFrames
//
//        let firstFrame = megaManWalking[0]
//        megaMan = SKSpriteNode(texture: firstFrame)
//        megaMan.position = CGPoint(x:CGRectGetMinX(self.frame), y:CGRectGetMinY(self.frame))
//        addChild(megaMan)
//
//        let skView = self.view
//
//        skView?.showsNodeCount = true
//
//        let scene = GameScene(size: skView!.bounds.size)
//
//        scene.scaleMode = .AspectFit
//
//        skView?.presentScene(scene)
//
//
//        walkingMan()
//
//    }
//
//
//
//    func walkingMan() {
//        megaMan.runAction(SKAction.repeatActionForever(
//            SKAction.animateWithTextures(megaManWalking,
//                timePerFrame: 0.15,
//                resize: false,
//                restore: true)),
//                          withKey:"walkingInPlaceMan")
//    }
//
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }



//import Foundation
//import SpriteKit
//
//class GameLevelScene: SKScene {
//    var map : JSTileMap
//    var player: Player
//    var previousUpdateTime: NSTimeInterval = 0.0
//    var walls: TMXLayer
//    override init(size: CGSize) {
//        self.map = JSTileMap(named: "level1.tmx")
//        self.player = Player(imageNamed: "koalio_stand")
//        self.walls = map.layerNamed("walls")
//        super.init(size: size)
//
//        self.backgroundColor = SKColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
//        self.addChild(self.map)
//
//        self.player.position = CGPointMake(100, 50)
//        self.player.zPosition = 15
//        self.map.addChild(self.player)
//
//        self.userInteractionEnabled = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func update(currentTime: NSTimeInterval) {
//        var delta = currentTime - self.previousUpdateTime
//        if delta > 0.02 {
//            delta = 0.02
//        }
//
//        self.previousUpdateTime = currentTime
//        self.player.update(delta)
//
//        self.checkForAndResolveCollisionsForPlayer(player, layer: walls)
//        self.setViewpointCenter(self.player.position)
//    }
//
//    func tileRectFromTileCoords(coords: CGPoint) -> CGRect {
//        let levelHeight = self.map.mapSize.height * self.map.tileSize.height
//        let origin = CGPointMake(coords.x * self.map.tileSize.width, levelHeight - ((coords.y + 1) * (self.map.tileSize.height)))
//        return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height)
//    }
//
//    func tileGIDAtCoordinate(coord: CGPoint, layer: TMXLayer) -> Int {
//        let info = layer.layerInfo
//        return info.tileGidAtCoord(coord)
//    }
//
//    func checkForAndResolveCollisionsForPlayer(player: Player, layer: TMXLayer) {
//        player.onGround = false
//        for index in [7, 1, 3, 5, 0, 2, 6, 8] {
//            let playerBox = player.collisionBoundingBox()
//            let playerCoord = layer.coordForPoint(player.desiredPosition)
//
//            let column = index % 3
//            let row = index / 3
//            let tileCoord = CGPointMake(playerCoord.x + CGFloat(column - 1), playerCoord.y + CGFloat(row - 1))
//            let gid = self.tileGIDAtCoordinate(tileCoord, layer: layer)
//            if (gid > 0) {
//                let tileRect = self.tileRectFromTileCoords(tileCoord)
//
//                if (CGRectIntersectsRect(playerBox, tileRect)) {
//                    let intersection = CGRectIntersection(playerBox, tileRect).size
//                    switch(index) {
//                    case 7:
//                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.height)
//                        player.velocity = CGPointMake(player.velocity.x, 0.0)
//                        player.onGround = true
//                    case 1:
//                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.height)
//                    case 3:
//                        player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.width, player.desiredPosition.y)
//                    case 5:
//                        player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.width, player.desiredPosition.y)
//                    default:
//                        if (intersection.width > intersection.height) {
//                            player.velocity = CGPointMake(player.velocity.x, 0.0)
//                            var height = intersection.height
//                            if index > 4 {
//                                player.onGround = true
//                            } else {
//                                height *= -1
//                            }
//                            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + height)
//                        } else {
//                            let width = index == 6 || index == 0 ? intersection.width : -intersection.width
//                            player.desiredPosition = CGPointMake(player.desiredPosition.x  + width, player.desiredPosition.y)
//                        }
//                    }
//
//                }
//            }
//        }
//        player.position = player.desiredPosition
//    }
//
//    func setViewpointCenter(center: CGPoint) {
//        var x = max(center.x, self.size.width / 2)
//        var y = max(center.y, self.size.height / 2)
//
//        x = min(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2)
//        y = min(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2)
//
//        let position = CGPointMake(x, y)
//        let center = CGPointMake(self.size.width / 2, self.size.height / 2)
//        let viewPoint = CGPointSubtract(center, position)
//        self.map.position = viewPoint
//    }
//
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touchObject in touches {
//            let touch = touchObject
//            let location = touch.locationInNode(self)
//            if location.x < self.size.width / 2 {
//                self.player.moving = true
//            } else {
//                self.player.jumping = true
//            }
//        }
//    }
//
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let halfWidth = self.size.width / 2.0
//        for touchObject in touches {
//            let touch = touchObject
//            let location = touch.locationInNode(self)
//
//            let previousLocation = touch.previousLocationInNode(self)
//            if location.x > halfWidth && previousLocation.x <= halfWidth {
//                self.player.moving = false
//                self.player.jumping = true
//            } else if previousLocation.x > halfWidth && location.x <= halfWidth {
//                self.player.moving = true
//                self.player.jumping = false
//            }
//        }
//    }
//
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touchObject in touches {
//            let touch = touchObject
//            let location = touch.locationInNode(self)
//            if location.x < self.size.width / 2.0 {
//                self.player.moving = false
//            } else {
//                self.player.jumping = false
//            }
//        }
//    }
//