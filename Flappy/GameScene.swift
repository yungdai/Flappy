//
//  GameScene.swift
//  Flappy
//
//  Created by Yung Dai on 2015-05-20.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // declariations of different elements on the scren
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipeDown = SKSpriteNode()
    var pipeUp = SKSpriteNode()
    var ground = SKSpriteNode()
    var pipes = SKNode()
    var startGround = SKNode()
    let startGameText = SKLabelNode(fontNamed: "System")
    
    // define an action for the pipes movmement
    var movePipesAndRemovePipes: SKAction!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let birdTexture = SKTexture(imageNamed: "wingdown")
        let birdTexture2 = SKTexture(imageNamed: "wingup")
        birdTexture.filteringMode = .Linear
        birdTexture2.filteringMode = .Linear
        
  
        
        // animation for the bird
        var animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.2)
        var makeFlap = SKAction.repeatActionForever(animation)
        
        // start game setup
        startGameText.text = "Let's Get Flapping!"
        startGameText.fontSize = 30
        startGameText.position = CGPoint(x: self.frame.size.width * 0.55, y: CGRectGetMidY(self.frame))
        startGameText.zPosition = 15
        
        // draw the start game to the scene
        self.addChild(startGameText)
        
        
        // assigning the texture to the bird sprite node
        bird = SKSpriteNode(texture: birdTexture)
        
        // set the positio of the bird
        bird.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        // now run it's animation
        bird.runAction(makeFlap)
        
        // adding physics for Flappy
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        
        // set the position of the bird to the forground
        bird.zPosition = 10
        
        
        // assignging the textures to the two different pipes then filter the texture with Bi-linear Filtering (BLF)
        let pipeDownTexture = SKTexture(imageNamed: "pipe1")
        let pipeUpTexture = SKTexture(imageNamed: "pipe2")
        pipeDownTexture.filteringMode = .Linear
        pipeUpTexture.filteringMode = .Linear
        

        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        

        // add a backbground image and use BLF for the filtering
        let backgroundImage = SKTexture(imageNamed: "bg")
        backgroundImage.filteringMode = .Linear
        background = SKSpriteNode(texture: backgroundImage)
        
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size.height = self.frame.height
        background.zPosition = 0;
        self.addChild(background)
        
        
        // moving the background from left to right, then replacing it
        var shiftBackground = SKAction.moveByX(-background.size.width, y: 0, duration: 10)
        var replaceBackground = SKAction.moveByX(background.size.width, y: 0, duration: 0)
        
        var movingAndReplacingBackground = SKAction.repeatActionForever(SKAction.sequence([shiftBackground,replaceBackground]))
        
        for var i:CGFloat = 0; i < 2 + self.frame.size.width/(backgroundImage.size().width * 2); i++ {
            // defining background; giving it height and moving width
            // set the position fo the background
            var movingBackground = SKSpriteNode(texture: backgroundImage)
            movingBackground.position = CGPoint(x: backgroundImage.size().width / 2 + backgroundImage.size().width * i, y: CGRectGetMidY(self.frame))
            movingBackground.size.height = self.frame.height
            movingBackground.runAction(movingAndReplacingBackground)
            self.addChild(movingBackground)
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
            self.addChild(movingGround)
        }
        
        // set the start ground position
        startGround.position = CGPointMake(0, 0)
        
        // set the ground physics
        startGround.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, self.frame.size.height * 0.75))
        startGround.physicsBody?.dynamic = false
        
    
        
        // add the ground to the screen
        self.addChild(startGround)

        // draw the bird onto the screen
        self.addChild(bird)
        

    }
    
    // funcation for spawning pipes
//    func spawnPipes() {
//        let pipePair = SKNode()
//        pipePair.position = CGPointMake( self.frame.size.width + pipeTextureUp.size().width * 2, 0 )
//        pipePair.zPosition = -10
//        
//        let height = UInt32( UInt(self.frame.size.height / 4) )
//        let y = arc4random() % height + height
//        
//        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
//        pipeDown.setScale(2.0)
//        pipeDown.position = CGPointMake(0.0, CGFloat(Double(y)) + pipeDown.size.height + CGFloat(verticalPipeGap))
//        
//        
//        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
//        pipeDown.physicsBody?.dynamic = false
//        pipeDown.physicsBody?.categoryBitMask = pipeCategory
//        pipeDown.physicsBody?.contactTestBitMask = birdCategory
//        pipePair.addChild(pipeDown)
//        
//        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
//        pipeUp.setScale(2.0)
//        pipeUp.position = CGPointMake(0.0, CGFloat(Double(y)))
//        
//        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
//        pipeUp.physicsBody?.dynamic = false
//        pipeUp.physicsBody?.categoryBitMask = pipeCategory
//        pipeUp.physicsBody?.contactTestBitMask = birdCategory
//        pipePair.addChild(pipeUp)
//        
//        var contactNode = SKNode()
//        contactNode.position = CGPointMake( pipeDown.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) )
//        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( pipeUp.size.width, self.frame.size.height ))
//        contactNode.physicsBody?.dynamic = false
//        contactNode.physicsBody?.categoryBitMask = scoreCategory
//        contactNode.physicsBody?.contactTestBitMask = birdCategory
//        pipePair.addChild(contactNode)
//        
//        pipePair.runAction(movePipesAndRemove)
//        pipes.addChild(pipePair)
//        
//    }

    

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        // set how high you want flappy to go
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 250))
        
        println("Flappy is flying")
        for touch : AnyObject in touches {
            let location = touch.locationInNode(self)


            
            // if you are touching inside the bounding box of the startGame Text
            if startGameText.containsPoint(location) {
                println("Start is being tapped")
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
