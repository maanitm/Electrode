//
//  GameLevelScene.m
//  SuperKoalio
//
//  Created by Jake Gundersen on 12/27/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "GameLevelScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTAudio.h"
#import "SKTUtils.h"
#import "ViewController.h"

@interface GameLevelScene()

@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, strong) Player *player;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;
@property (nonatomic, strong) TMXLayer *walls;
@property (nonatomic, strong) TMXLayer *hazards;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, strong) SKSpriteNode *exitButton;
@property (nonatomic, strong) SKSpriteNode *infoButton;
@property (nonatomic, strong) SKLabelNode *infoButtonText;
@property (nonatomic, strong) SKLabelNode *exitButtonText;
@property (nonatomic, strong) SKLabelNode *timerLabel;
@property (nonatomic, assign) int currentTimer;
@property (nonatomic, assign) NSTimer *timer;

@end

@implementation GameLevelScene

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    [[SKTAudio sharedInstance] playBackgroundMusic:@"level1.mp3"];
    
    self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
    
    self.map = [JSTileMap mapNamed:[NSString stringWithFormat:@"level%@.tmx", [[NSUserDefaults standardUserDefaults] objectForKey:@"Level"]]];
    [self addChild:self.map];
    self.walls = [self.map layerNamed:@"walls"];
    self.hazards = [self.map layerNamed:@"hazards"];
    
    self.player = [[Player alloc] initWithImageNamed:@"electrode_stand"];
    self.player.size = CGSizeMake(15, 37);
    self.player.position = CGPointMake(100, 50);
    self.player.zPosition = 15;
    [self.map addChild:self.player];
    
    self.timerLabel = [[SKLabelNode alloc] initWithFontNamed:@"Marker Felt"];
    self.timerLabel.position = CGPointMake(150, self.frame.size.height - 20);
    self.timerLabel.text = @"0m 0s";
    self.timerLabel.fontSize = 24;
    self.timerLabel.fontColor = [UIColor whiteColor];
    [self addChild:self.timerLabel];
    
    self.exitButtonText = [[SKLabelNode alloc] initWithFontNamed:@"Marker Felt"];
    self.exitButtonText.position = CGPointMake(23, self.frame.size.height - 20);
    self.exitButtonText.text = @"Quit!";
    self.exitButtonText.fontSize = 24;
    self.exitButtonText.fontColor = [UIColor whiteColor];
    [self addChild:self.exitButtonText];
    
    self.exitButton = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.exitButtonText.frame.size.width, self.exitButtonText.frame.size.height)];
    self.exitButton.position = CGPointMake(self.exitButtonText.position.x, self.exitButtonText.position.y + 10);
    [self insertChild:self.exitButton atIndex:2];
    
    self.infoButtonText = [[SKLabelNode alloc] initWithFontNamed:@"Marker Felt"];
    self.infoButtonText.position = CGPointMake(23, self.frame.size.height - 20);
    self.infoButtonText.text = @"Quit!";
    self.infoButtonText.fontSize = 24;
    self.infoButtonText.fontColor = [UIColor whiteColor];
    [self addChild:self.infoButtonText];
    
    self.infoButton = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.infoButtonText.frame.size.width, self.infoButton.frame.size.height)];
    self.infoButton.position = CGPointMake(self.infoButton.position.x, self.infoButton.position.y + 10);
    [self insertChild:self.infoButton atIndex:2];
    
    self.userInteractionEnabled = YES;
    
    [self startTimer];
  }
  return self;
}

//You are Electrode and you have to get to the generator to provide electricity for the city! Oh wait, there is one problem ... You have to fight the fire and avoid getting burnt so the power plant has a good efficiency. Good luck!

- (void)timerUpdate {
  self.currentTimer++;
  NSString *currentTime = [NSString stringWithFormat:@"%dm %ds", (int)(self.currentTimer / 60), (int)(self.currentTimer % 60)];
  self.timerLabel.text = currentTime;
}

- (void)startTimer {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
}
- (void)endTimer {
  [self.timer fire];
  [self.timer invalidate];
  self.timer = nil;
}

- (void)restartTimer {
  [self endTimer];
  [self startTimer];
}

- (void)update:(NSTimeInterval)currentTime
{
  if (self.gameOver) return;

  NSTimeInterval delta = currentTime - self.previousUpdateTime;

  if (delta > 0.02) {
    delta = 0.02;
  }

  self.previousUpdateTime = currentTime;

  [self.player update:delta];
  
  [self checkForAndResolveCollisionsForPlayer:self.player forLayer:self.walls];
  [self handleHazardCollisions:self.player]; 
  [self checkForWin];
  [self setViewpointCenter:self.player.position];
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords
{
  float levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x * self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
  return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height);
}

- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer
{
  TMXLayerInfo *layerInfo = layer.layerInfo;
  return [layerInfo tileGidAtCoord:coord];
}

- (void)checkForAndResolveCollisionsForPlayer:(Player *)player forLayer:(TMXLayer *)layer
{
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  player.onGround = NO;  ////Here
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [layer coordForPoint:player.desiredPosition];
    
    if (playerCoord.y >= self.map.mapSize.height - 1) {
      [self gameOver:0];
      return;
    }
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:layer];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      //NSLog(@"GID %ld, Tile Coord %@, Tile Rect %@, player rect %@", (long)gid, NSStringFromCGPoint(tileCoord), NSStringFromCGRect(tileRect), NSStringFromCGRect(playerRect));
      //1
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        CGRect intersection = CGRectIntersection(playerRect, tileRect);
        //2
        if (tileIndex == 7) {
          //tile is directly below Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
          player.onGround = YES;
        } else if (tileIndex == 1) {
          //tile is directly above Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
        } else if (tileIndex == 3) {
          //tile is left of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
        } else if (tileIndex == 5) {
          //tile is right of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
          //3
        } else {
          if (intersection.size.width > intersection.size.height) {
            //tile is diagonal, but resolving collision vertically
            //4
            player.velocity = CGPointMake(player.velocity.x, 0.0); ////Here
            float intersectionHeight;
            if (tileIndex > 4) {
              intersectionHeight = intersection.size.height;
              player.onGround = YES; ////Here
            } else {
              intersectionHeight = -intersection.size.height;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height );
          } else {
            //tile is diagonal, but resolving horizontally
            float intersectionWidth;
            if (tileIndex == 6 || tileIndex == 0) {
              intersectionWidth = intersection.size.width;
            } else {
              intersectionWidth = -intersection.size.width;
            }
            //5
            player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y);
          }
        }
      }
    }
  }
  //6
  player.position = player.desiredPosition;
}

- (void)handleHazardCollisions:(Player *)player
{
  if (self.gameOver) return;
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};

  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.hazards coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.hazards];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        [self gameOver:0];
      }
    }
  }
}

-(void)checkForWin {
  if (self.player.position.x > 3130.0) {
    [self gameOver:1];
  }
}

-(void)gameOver:(BOOL)won {
  self.gameOver = YES;
  [self runAction:[SKAction playSoundFileNamed:@"hurt.wav" waitForCompletion:NO]];
  
  NSString *gameText;
  
  if (won) {
    gameText = @"You Won!";
  } else {
    gameText = @"You have Died!";
  }
  
  [self endTimer];
	
  //1
  SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  endGameLabel.text = gameText;
  endGameLabel.fontSize = 40;
  endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
  [self addChild:endGameLabel];
  
  //2
  UIButton *replay = [UIButton buttonWithType:UIButtonTypeCustom];
  replay.tag = 321;
  UIImage *replayImage = [UIImage imageNamed:@"replay"];
  [replay setImage:replayImage forState:UIControlStateNormal];
  [replay addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
  replay.frame = CGRectMake(self.size.width / 2.0 - replayImage.size.width / 2.0, self.size.height / 2.0 - replayImage.size.height / 2.0, replayImage.size.width, replayImage.size.height);
  [self.view addSubview:replay];
}

//3
- (void)replay:(id)sender
{
  [self startTimer];
  
  [[self.view viewWithTag:321] removeFromSuperview];
  [self.view presentScene:[[GameLevelScene alloc] initWithSize:self.size]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if ([self nodeAtPoint:[touch locationInNode:self]] == self.exitButtonText) {
      [self gameOver:0];
      [[[ViewController alloc] init] exitScene];
    }
    else {
      if (touchLocation.x < self.size.width / 2.0) {
        self.player.mightAsWellJump = YES;
      } else {
        self.player.forwardMarch = YES;
      }
    }
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    
    float halfWidth = self.size.width / 2.0;
    CGPoint touchLocation = [touch locationInNode:self];
    
    //get previous touch and convert it to node space
    CGPoint previousTouchLocation = [touch previousLocationInNode:self];
    
    if (touchLocation.x < halfWidth && previousTouchLocation.x >= halfWidth) {
      self.player.forwardMarch = NO;
      self.player.mightAsWellJump = YES;
    } else if (previousTouchLocation.x < halfWidth && touchLocation.x >= halfWidth) {
      self.player.forwardMarch = YES;
      self.player.mightAsWellJump = NO;
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x > self.size.width / 2.0) {
      self.player.forwardMarch = NO;
    } else {
      self.player.mightAsWellJump = NO;
    }
  }
}

- (void)setViewpointCenter:(CGPoint)position {
  NSInteger x = MAX(position.x, self.size.width / 2);
  NSInteger y = MAX(position.y, self.size.height / 2);
  x = MIN(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2);
  y = MIN(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2);
  CGPoint actualPosition = CGPointMake(x, y);
  CGPoint centerOfView = CGPointMake(self.size.width/2, self.size.height/2);
  CGPoint viewPoint = CGPointSubtract(centerOfView, actualPosition);
  self.map.position = viewPoint;
}

@end
