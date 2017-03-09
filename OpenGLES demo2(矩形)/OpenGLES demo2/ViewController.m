//
//  ViewController.m
//  OpenGLES demo2
//
//  Created by apple on 2/27/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "ViewController.h"
#import "RoundPointView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RoundPointView *view = [[RoundPointView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    
    
    [self.view addSubview:view];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSLog(@"size = %@, layer rect = %@   %f", NSStringFromCGSize(size),
          NSStringFromCGRect(self.view.layer.bounds),self.view.layer.bounds.size.width);
    NSLog(@"view = %@",NSStringFromCGRect(self.view.frame));
    
    [self.view setNeedsLayout];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
