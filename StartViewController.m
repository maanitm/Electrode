//
//  StartViewController.m
//  Electrode
//
//  Created by Maanit Madan on 12/2/15.
//  Copyright © 2015 Tecshala. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (UIButton *levelButton in self.levelButtons) {
        [self setRound:levelButton];
        [self animate:levelButton];
    }
}

BOOL turn = NO;

- (void)restart {
    for (UIButton *levelButton in self.levelButtons) {
        [self animate:levelButton];
    }
}

- (void)animate:(UIButton *)button {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (turn == NO) {
            button.transform = CGAffineTransformMakeRotation(M_PI);
            turn = YES;
        }
        else {
            button.transform = CGAffineTransformMakeRotation(M_PI*2);
            turn = NO;
        }
    } completion:^(BOOL finished) {
        [self restart];
    }];
}

- (void)setRound:(UIButton *)button {
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.width/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)level:(id)sender {
    UIButton *levelButton = (UIButton *)sender;
    
    if ([levelButton.titleLabel.text containsString:@"1"]) {
        NSLog(@"Worked");
    }
}

@end
