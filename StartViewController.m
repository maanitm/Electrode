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
    }
    [self restart];
}

BOOL turn = NO;

- (void)restart {
    for (UIButton *levelButton in self.levelButtons) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animate:) userInfo:levelButton repeats:YES];
    }
}

- (void)animate:(NSTimer *)timer {
    UIButton *button = (UIButton *)[timer userInfo];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (turn == NO) {
            button.transform = CGAffineTransformMakeScale(1.3, 1.3);
            turn = YES;
        }
        else {
            button.transform = CGAffineTransformMakeScale(1, 1);
            turn = NO;
        }
    } completion:nil];
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
    
    NSString *levelString;
    levelString = levelButton.titleLabel.text;
    levelString = [levelString componentsSeparatedByString:@"Level "][1];
    
    [[NSUserDefaults standardUserDefaults] setObject:levelString forKey:@"Level"];
    
    [self performSegueWithIdentifier:@"start" sender:self];
}

@end
