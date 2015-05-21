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
    var groundBoundary = SKNode()
    var skyBoundary = SKNode()
    let startGameText = SKLabelNode(fontNamed: "System")
  
    
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

        // draw a custom physics body using a polygonline, you can get your own from these two websites
        // http://insyncapp.net/SKPhysicsBodyPathGenerator.html
        // to convert that code to swift http://avionicsdev.esy.es/article.php?id=13&page=1
        
        let path: CGMutablePathRef = CGPathCreateMutable()
        

        MoveToPoint(path, x: 24, y: 57, node: bird)
        AddLineToPoint(path, x: 7, y: 26, node: bird)
        AddLineToPoint(path, x: 18, y: 9, node: bird)
        AddLineToPoint(path, x: 55, y: 16, node: bird)
        AddLineToPoint(path, x: 61, y: 24, node: bird)
        AddLineToPoint(path, x: 46, y: 41, node: bird);
        AddLineToPoint(path, x: 39, y: 52, node: bird)
        AddLineToPoint(path, x: 30, y: 56, node: bird)
        
        CGPathCloseSubpath(path)

        bird.physicsBody = SKPhysicsBody(polygonFromPath: path)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        // assgining collsionBitMask to the bird
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        
        // test to see if the bird hit the pipe
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory

        
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
    func spawnPipes() {
        var pipePair = SKSpriteNode()
        
        // creating a gap between the pipe
        var gap = bird.size.height * 2
        
        // movement amount
        var movementAmount = arc4random() % UInt32(self.frame.size.height / 5)
        
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
        
        
        // drawing a set of pipes onto the screen
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeDown.size.height / 2 + gap / 2 + pipeOffset)
        // if the pipe contacts the bird
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)


        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeUp.size.height / 2 - gap / 2 + pipeOffset)
        // if the pipe contacts the bird
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
        
        var contactNode = SKNode()

        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeUp.size.width, self.frame.size.height))
        contactNode.position = CGPoint(x: CGRectGetMidX(self.frame) + self.size.width, y: CGRectGetMidY(self.frame) - pipeUp.size.height  / 2 - gap / 2 + pipeOffset)
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        
        
        
        pipePair.runAction(moveAndRemovePipes)
        self.addChild(pipePair)
 
    }
    
    
    // functions for the bird roation
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        bird.zRotation = self.clamp( -1, max: 0.5, value: bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
    }

    
    // function to reset the scene
    
    func resetScene() {
        
        // set the positio of the bird
        bird.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        // reset all the pipes by removing them fromt the screen
        self.removeAllChildren()
        
        // reset score
        score = 0
        scoreLabel.text = String(score)
    
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
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        // set how high you want flappy to go
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        
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
    
    // new function to detech when two physicsBody's touch each other
    func didBeginContact(contact: SKPhysicsContact) {

    }

}
