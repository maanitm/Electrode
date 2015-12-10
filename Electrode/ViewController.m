//
//  ViewController.m
//  Electrode
//
//  Created by Jake Gundersen on 12/27/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "ViewController.h"
#import "GameLevelScene.h"

@implementation ViewController

SKView *skView;
SKScene *scene;

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  // Configure the view.
  skView = (SKView *)self.view;
  skView.showsFPS = NO;
  skView.showsNodeCount = NO;
  
  // Create and configure the scene.
  scene = [GameLevelScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  // Present the scene.
  [skView presentScene:scene];
}

- (void)exitScene {
  exit(0);
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end
