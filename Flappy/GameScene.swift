//
//  GameScene.swift
//  Flappy
//
//  Created by Yung Dai on 2015-05-20.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate //SKPhysicsContactDelegate is for the contat physics

{
    
    // declariations of different elements on the scren
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipeDown = SKSpriteNode()
    var pipeUp = SKSpriteNode()
    var ground = SKSpriteNode()
    var groundBoundary = SKNode()
    var skyBoundary = SKNode()
    let startGameText = SKLabelNode(fontNamed: "System")
    let gameOverText = SKLabelNode(fontNamed: "System")
    let sparkEmitter = SKEmitterNode(fileNamed: "sparkles")
    var moving = SKNode()
    var pipes = SKNode()
    var restart = Bool()
    var flapSound = AVAudioPlayer()
    var gameOverSound = AVAudioPlayer()
  
    
    // setup the score
    let scoreLabel = SKLabelNode()
    var score = 0
    
    // objects Categories for the physicsBitMask
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    
    
    // define an action for the pipes movmement
    var movePipesAndRemovePipes: SKAction!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        restart = false
        
        let birdTexture = SKTexture(imageNamed: "wingdown")
        let birdTexture2 = SKTexture(imageNamed: "wingup")
        birdTexture.filteringMode = .Linear
        birdTexture2.filteringMode = .Linear
  
        
        
        // setup world physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        self.physicsWorld.contactDelegate = self
        
        
        // create a SKNode for all moving objects
        moving = SKNode()
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        
        // set up the audio
        audioPreparation()
        
        // setup the sparkle parti
        
        // animation for the bird
        var animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.2)
        var makeFlap = SKAction.repeatActionForever(animation)
        

        
        // start game setup
        startGameText.text = "Let's Get Flapping!"
        startGameText.fontSize = 30
        startGameText.position = CGPoint(x: self.frame.size.width * 0.55, y: CGRectGetMidY(self.frame))
        startGameText.zPosition = 15
        
        
        // game over text setup
        gameOverText.text = "Game Over!"
        gameOverText.fontSize = 30
        gameOverText.position = CGPoint(x: self.frame.size.width * 0.55, y: CGRectGetMidY(self.frame))
        gameOverText.zPosition = 15
        
        // draw the start game to the scene
        self.addChild(startGameText)
        
        
        // assigning the texture to the bird sprite node
        bird = SKSpriteNode(texture: birdTexture)
        
        // set the positio of the bird
        bird.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        //bird.physicsBody = SKPhysicsBody(texture: birdTexture, size: CGSize(width: birdTexture.size().width, height: birdTexture.size().height))
        
        // now run it's animation
        bird.runAction(makeFlap)
        
        
        
        // set the position of the bird to the forground
        bird.zPosition = 10
        

        // add a backbground image and use BLF for the filtering
        let backgroundImage = SKTexture(imageNamed: "colored_castle")
        backgroundImage.filteringMode = .Linear
        background = SKSpriteNode(texture: backgroundImage)
        
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size.height = self.frame.height
        background.zPosition = 0;
        
        
        // moving the background from left to right, then replacing it
        var shiftBackground = SKAction.moveByX(-background.size.width, y: 0, duration: 10)
        var replaceBackground = SKAction.moveByX(background.size.width, y: 0, duration: 0)
        
        var movingAndReplacingBackground = SKAction.repeatActionForever(SKAction.sequence([shiftBackground,replaceBackground]))
        
        for var i:CGFloat = 0; i < 2 + self.frame.size.width/(backgroundImage.size().width * 1); i++ {
            // defining background; giving it height and moving width
            // set the position fo the background
            var movingBackground = SKSpriteNode(texture: backgroundImage)
            movingBackground.position = CGPoint(x: backgroundImage.size().width / 2 + backgroundImage.size().width * i, y: CGRectGetMidY(self.frame))
            movingBackground.size.height = self.frame.height
            movingBackground.runAction(movingAndReplacingBackground)
            moving.addChild(movingBackground)
        }
        
        
        
        
        //define ground object
        let groundImage = SKTexture(imageNamed: "land")
        groundImage.filteringMode = SKTextureFilteringMode.Nearest
        
        
        // moving the ground from left to right, then replacing it
        var shiftGround = SKAction.moveByX(-groundImage.size().width, y: 0, duration: 3)
        var replaceGround = SKAction.moveByX(groundImage.size().width, y: 0, duration: 0)
        
        var movingAndReplacingGround = SKAction.repeatActionForever(SKAction.sequence([shiftGround,replaceGround]))
        
        for var i:CGFloat = 0; i < 2 + self.frame.size.width/(groundImage.size().width * 1); i++ {
            // defining background; giving it height and moving width
            // set the position fo the background
            var movingGround = SKSpriteNode(texture: groundImage)
            movingGround.position = CGPoint(x: groundImage.size().width / 2 + groundImage.size().width * i, y: 0)
            movingGround.size.height = self.frame.height / 2.75
            movingGround.runAction(movingAndReplacingGround)
            
            // add the moving ground to the moving SKNode
            moving.addChild(movingGround)
        }
        
        
        // setup the score label
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 100
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 2 + 200)
        scoreLabel.zPosition = 15
        self.addChild(scoreLabel)
            
        // set the ground bondary position
        groundBoundary.position = CGPointMake(0, 0)
        
        // set the ground physics
        groundBoundary.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, self.frame.size.height * 0.3))
        groundBoundary.physicsBody?.dynamic = false
        
        // set the sky boundary position
        skyBoundary.position = CGPointMake(0, CGRectGetMaxY(self.frame))
        
        // set the sky boundary physics
        skyBoundary.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, self.frame.size.height * 0.2))
        skyBoundary.physicsBody?.dynamic = false
       
        
        // add the ground and sky contacts to the screen
        self.addChild(groundBoundary)
        self.addChild(skyBoundary)

        // draw the bird onto the screen
        self.addChild(bird)
        

    }
    
    // funcation for spawning pipes
    func makePipes() {
        var pipePair = SKSpriteNode()
        
        // creating a gap between the pipe
        var gap = bird.size.height * 2
        
        // movement amount
        var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        
        // gap offset for the pipe
        var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 3.5
        
        //  move the pipes
        let shiftPipes = SKAction.moveByX(-self.frame.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        
        let  scoreValue = SKAction.runBlock { () -> Void in
            self.score++
            self.scoreLabel.text = "\(self.score)"
            self.scoreLabel.zPosition = 15
        }
          
        // move and remove pipes
        var moveAndRemovePipes = SKAction.repeatActionForever(SKAction.sequence([shiftPipes, scoreValue, removePipes]))
        
        
        // creating the pipes
        let pipeDownTexture = SKTexture(imageNamed: "pipe1")
        let pipeUpTexture = SKTexture(imageNamed: "pipe2")
        pipeDownTexture.filteringMode = .Linear
        pipeUpTexture.filteringMode = .Linear
        pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeDown.zPosition = 10
        pipeUp.zPosition = 10
        pipePair.zPosition = 10
        pipePair.physicsBody?.categoryBitMask = pipeCategory | worldCategory
        
        
        // drawing a set of pipes onto the screen
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeDown.size.height / 2 + gap / 2 + pipeOffset)
        // if the pipe contacts the bird
        pipeDown.physicsBody?.categoryBitMask = pipeCategory | worldCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)


        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeUp.size.height / 2 - gap / 2 + pipeOffset)
        // if the pipe contacts the bird
        pipeUp.physicsBody?.categoryBitMask = pipeCategory | worldCategory
        pipeUp.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
        
        
        pipePair.runAction(moveAndRemovePipes)
        pipes.addChild(pipePair)
 
    }
    
    
//     functions for the bird roation
    
//    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
//        if( value > max ) {
//            return max
//        } else if( value < min ) {
//            return min
//        } else {
//            return value
//        }
//    }
//    
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//        bird.zRotation = self.clamp( -1, max: 0.5, value: bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
//    }

    
    // function to reset the scene
    
    func resetScene() {
        
        // set the positio of the bird
        bird.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        bird.physicsBody?.velocity = CGVectorMake( 0, 0 )
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.physicsBody?.allowsRotation = false
        bird.zRotation = 0.0
        
        // reset all the pipes by removing them fromt the screen
        pipes.removeAllChildren()
        
        // reset score
        score = 0
        scoreLabel.text = String(score)
        
        // reset the moving speed
        
        moving.speed = 1
    
    }
    
    // new functions for the custom polygon path, I have to multiply the values by 2 to make sure that the polygone matches the size of my SKNodeSprite
    func offset(node: SKSpriteNode, isX: Bool)->CGFloat {
        return isX ? node.frame.size.width * node.anchorPoint.x : node.frame.size.height * node.anchorPoint.y
    }
    
    func AddLineToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathAddLineToPoint(path, nil, (x * 2) - offset(node, isX: true), (y * 2) - offset(node, isX: false))
    }
    
    func MoveToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathMoveToPoint(path, nil, (x * 2) - offset(node, isX: true), (y * 2) - offset(node, isX: false))
    }
    
    
    // functon for flapping sound
    
    func audioPreparation() {
        // set the soudn file name and extension
        var flap  = NSBundle.mainBundle().pathForResource("flap", ofType: "wav")
//        var march = NSBundle.mainBundle().pathForResource("march", ofType: "mp3")
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        flapSound = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: flap!), error: &error)
        flapSound.prepareToPlay()
        
//        gameOverSound = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: march!), error: &error)
//        gameOverSound.prepareToPlay()
//        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        // set how high you want flappy to go
        if moving.speed > 0 {
        
            println("Flappy is flying")
        
        
            for touch : AnyObject in touches {
                let location = touch.locationInNode(self)
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 80))
                
                // play a flapping sound each time the bird is touched
                flapSound.play()
                
                
    
                if bird.containsPoint(location) {

                }

            
                // if you are touching inside the bounding box of the startGame Text
                if startGameText.containsPoint(location) {
                    println("Start is being tapped")
                
                    let birdTexture = SKTexture(imageNamed: "wingdown")
                    let birdTexture2 = SKTexture(imageNamed: "wingup")
                    birdTexture.filteringMode = .Linear
                    birdTexture2.filteringMode = .Linear
                
                    bird.physicsBody = SKPhysicsBody(texture: birdTexture, size: CGSize(width: birdTexture.size().width, height: birdTexture.size().height))
                    bird.physicsBody?.dynamic = true
                    bird.physicsBody?.allowsRotation = false
                    // assgining collsionBitMask to the bird
                    bird.physicsBody?.categoryBitMask = birdCategory
                    bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
                
                    // test to see if the bird hit the pipe
                    bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
                    var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: ("makePipes"), userInfo: nil, repeats: true)
                    self.startGameText.removeFromParent()
                

                }
                
                if gameOverText.containsPoint(location) {
                    println("Gameover is being touched")
                    restart = true
                    self.gameOverText.removeFromParent()
                }
            }
        } else if restart {
            self.resetScene()
        }
    }
    
    
    
    // new function to detech when two physicsBody's touch each other
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if (contact.bodyA.categoryBitMask & worldCategory) == worldCategory || (contact.bodyB.categoryBitMask & worldCategory) == worldCategory {
            println("Bird has contact with a world object")
            // stop moving when you collide
            moving.speed = 0
            bird.physicsBody?.collisionBitMask = worldCategory
            // show the gameover text
//            self.addChild(gameOverText)
            restart = true
            gameOverSound.play()
            
        }

    }

}
