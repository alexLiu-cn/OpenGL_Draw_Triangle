//
//  ViewController.m
//  FirstOpenGLDemo
//
//  Created by apple on 2/26/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "ViewController.h"
#import "MyGLView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //
    MyGLView *myGlView = [[MyGLView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [self.view addSubview:myGlView];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
