//
//  GameObjectNode.swift
//  FPPlatformingGame
//
//  Created by Colin Walsh on 7/8/16.
//  Copyright © 2016 Colin Walsh. All rights reserved.
//

import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

enum PlatformType: Int {
    case Normal = 0
    case Break
}

class GameObjectNode: SKNode {
    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // 1
        // Only bounce the player if he's falling
        if player.physicsBody?.velocity.dy < 0 {
            // 2
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250.0)
            
            // 3
            // Remove if it is a Break type platform
            if platformType == .Break {
                self.removeFromParent()
            }
        }
        
        // 4
        // No stars for platforms
        return false
    }
}