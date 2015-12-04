//
//  StartViewController.h
//  Electrode
//
//  Created by Maanit Madan on 12/2/15.
//  Copyright © 2015 Tecshala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *levelButtons;

- (IBAction)level:(id)sender;


@end
