//
//  ViewController.m
//  opengl_demo4
//
//  Created by apple on 3/7/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "ViewController.h"
#import "BGGLView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BGGLView *view = [[BGGLView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:view];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
