//
//  GameScene.swift
//  FPPlatformingGame
//
//  Created by Colin Walsh on 7/6/16.
//  Copyright (c) 2016 Colin Walsh. All rights reserved.
//

import SpriteKit

//var megaMan : SKSpriteNode!
//var megaManWalking : [SKTexture]!




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Layered Nodes
   // var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    // Player
    var player: SKNode!
    
    // To Accommodate iPhone 6
    var scaleFactor: CGFloat!
    
    // Tap To Start node
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.blackColor()
        
        scaleFactor = self.size.width / 320.0
        
        // Create the game nodes
        // Background
//        backgroundNode = createBackgroundNode()
//        addChild(backgroundNode)
        
        // Foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        // Add the player
        player = createPlayer()
        foregroundNode.addChild(player)
        
        // Add some gravity
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        // HUD
        hudNode = SKNode()
        addChild(hudNode)
        
        // Tap to Start
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        hudNode.addChild(tapToStartNode)
        
        let platform = createPlatformAtPosition(CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)), ofType: .Normal)
        foregroundNode.addChild(platform)
    }
    
//    func createBackgroundNode() -> SKNode {
//        // 1
//        // Create the node
//        let backgroundNode = SKNode()
//        let ySpacing = 64.0 * scaleFactor
//        
//        // 2
//        // Go through images until the entire background is built
//        for index in 0...19 {
//            // 3
//            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))
//            // 4
//            node.setScale(scaleFactor)
//            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
//            //5
//            backgroundNode.addChild(node)
//        }
//        
//        // 6
//        // Return the completed background node
//        return backgroundNode
//    }
    
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        let sprite = SKSpriteNode(imageNamed: "man1")
        playerNode.addChild(sprite)
        
        // 1
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        // 2
        playerNode.physicsBody?.dynamic = false
        // 3
        playerNode.physicsBody?.allowsRotation = false
        // 4
 
        playerNode.physicsBody?.restitution = 2.0
        playerNode.physicsBody?.friction = 1.0
        playerNode.physicsBody?.angularDamping = 10.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        // 1
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        // 2
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        // 3
        playerNode.physicsBody?.collisionBitMask = 0
        // 4
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
        return playerNode
    }
    
    func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        // 1
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        // 2
        var sprite: SKSpriteNode
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "Spaceship")
        } else {
            sprite = SKSpriteNode(imageNamed: "Spaceship")
        }
        node.addChild(sprite)
        
        // 3
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1
        // If we're already playing, ignore touches
        if player.physicsBody!.dynamic {
            return
        }
        
        // 2
        // Remove the Tap to Start node
        tapToStartNode.removeFromParent()
        
        // 3
        // Start the player by putting them into the physics simulation
        player.physicsBody?.dynamic = true
        
        // 4
         player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)
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

