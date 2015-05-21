//
//  GameScene.swift
//  Flappy
//
//  Created by Yung Dai on 2015-05-20.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate //SKPhysicsContactDelegate is for the contat physics

{
    
    // declariations of different elements on the scren
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipeDown = SKSpriteNode()
    var pipeUp = SKSpriteNode()
    var ground = SKSpriteNode()
    var pipes = SKNode()
    var groundBoundary = SKNode()
    var skyBoundary = SKNode()
    let startGameText = SKLabelNode(fontNamed: "System")
    var moving = SKNode()
    
    // setup the score
    var scoreLabel = SKLabelNode()
    var score = 0
    
    
    
    // define an action for the pipes movmement
    var movePipesAndRemovePipes: SKAction!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let birdTexture = SKTexture(imageNamed: "wingdown")
        let birdTexture2 = SKTexture(imageNamed: "wingup")
        birdTexture.filteringMode = .Linear
        birdTexture2.filteringMode = .Linear
        
        
        // setup world physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        self.physicsWorld.contactDelegate = self
  
        
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
//        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        

        
        let offsetX: CGFloat = bird.frame.size.width * bird.anchorPoint.x
        let offsetY: CGFloat = bird.frame.size.height * bird.anchorPoint.y
        
        let path: CGMutablePathRef = CGPathCreateMutable()
        
//        CGPathMoveToPoint(path, nil, 14 - offsetX, 57 - offsetY);
        MoveToPoint(path, x: 24, y: 57, node: bird)
//        CGPathAddLineToPoint(path, nil, 7 - offsetX, 26 - offsetY);
        AddLineToPoint(path, x: 7, y: 26, node: bird)
//        CGPathAddLineToPoint(path, nil, 18 - offsetX, 9 - offsetY);
        AddLineToPoint(path, x: 18, y: 9, node: bird)
//        CGPathAddLineToPoint(path, nil, 55 - offsetX, 16 - offsetY);
        AddLineToPoint(path, x: 55, y: 16, node: bird)
//        CGPathAddLineToPoint(path, nil, 61 - offsetX, 24 - offsetY);
        AddLineToPoint(path, x: 61, y: 24, node: bird)
//        CGPathAddLineToPoint(path, nil, 46 - offsetX, 41 - offsetY);
        AddLineToPoint(path, x: 46, y: 41, node: bird)
//        CGPathAddLineToPoint(path, nil, 39 - offsetX, 52 - offsetY);
        AddLineToPoint(path, x: 39, y: 52, node: bird)
//        CGPathAddLineToPoint(path, nil, 30 - offsetX, 56 - offsetY);
        AddLineToPoint(path, x: 30, y: 56, node: bird)
        
        CGPathCloseSubpath(path)

        bird.physicsBody = SKPhysicsBody(polygonFromPath: path)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        
        // set the position of the bird to the forground
        bird.zPosition = 10
        

        // add a backbground image and use BLF for the filtering
        let backgroundImage = SKTexture(imageNamed: "colored_castle")
        backgroundImage.filteringMode = .Linear
        background = SKSpriteNode(texture: backgroundImage)
        
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size.height = self.frame.height
        background.zPosition = 0;
//        self.addChild(background)
        
        
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
        
        
        // setup the score label
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 100
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 2 + 200)
        scoreLabel.zPosition = 11
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
        
        // setup a timer
//        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: ("spawnPipes"), userInfo: nil, repeats: true)
       
        
        // add the ground and sky contacts to the screen
        self.addChild(groundBoundary)
        self.addChild(skyBoundary)

        // draw the bird onto the screen
        self.addChild(bird)
        

    }
    
    // funcation for spawning pipes
    func spawnPipes() {
        
        
        // creating a gap between the pipe
        var gap = bird.size.height * 2
        
        // movement amount
        var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        
        // gap offset for the pipe
        var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 3.5
        
        //  move the pipes
        var shiftPipes = SKAction.moveByX(-self.frame.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        var removePipes = SKAction.removeFromParent()
        
        // move and remove pipes
        var moveAndRemovePipes = SKAction.repeatActionForever(SKAction.sequence([shiftPipes, removePipes]))
        
        
        // creating the pipes
        let pipeDownTexture = SKTexture(imageNamed: "pipe1")
        let pipeUpTexture = SKTexture(imageNamed: "pipe2")
        pipeDownTexture.filteringMode = .Linear
        pipeUpTexture.filteringMode = .Linear
        pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeDown.zPosition = 10
        pipeUp.zPosition = 10
        


        // drawing a set of pipes onto the screen

        pipeDown.runAction(moveAndRemovePipes)
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeDown.size.height / 2 + gap / 2 + pipeOffset)
        self.addChild(pipeDown)

        pipeUp.runAction(moveAndRemovePipes)
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeUp.size.height / 2 - gap / 2 + pipeOffset)
        self.addChild(pipeUp)
        

        
        
        
    }

    
    // function to reset the scene
    
    func resetScene() {
        
        // set the positio of the bird
        bird.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        // reset all the pipes by removing them fromt the screen
        pipes.removeAllChildren()
        
        
    
    
    
    }
    
    // new functions for the custom polygon path
    func offset(node: SKSpriteNode, isX: Bool)->CGFloat {
        return isX ? node.frame.size.width * node.anchorPoint.x : node.frame.size.height * node.anchorPoint.y
    }
    
    func AddLineToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathAddLineToPoint(path, nil, (x * 2) - offset(node, isX: true), (y * 2) - offset(node, isX: false))
    }
    
    func MoveToPoint(path: CGMutablePath!, x: CGFloat, y: CGFloat, node: SKSpriteNode) {
        CGPathMoveToPoint(path, nil, (x * 2) - offset(node, isX: true), (y * 2) - offset(node, isX: false))
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        // set how high you want flappy to go
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 250))
        
        println("Flappy is flying")
        for touch : AnyObject in touches {
            let location = touch.locationInNode(self)

            if bird.containsPoint(location) {

            }

            
            // if you are touching inside the bounding box of the startGame Text
            if startGameText.containsPoint(location) {
                println("Start is being tapped")
                // when I click the startGameText I start the timer and spawnPipes method
                var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: ("spawnPipes"), userInfo: nil, repeats: true)
                self.startGameText.removeFromParent()
                

            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
