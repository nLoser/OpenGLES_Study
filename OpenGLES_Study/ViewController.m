//
//  ViewController.m
//  OpenGLES_Study
//
//  Created by LV on 15/12/31.
//  Copyright © 2015年 Wieye. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"
@interface ViewController ()

@property (nonatomic, strong) OpenGLView * glView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.glView = [[OpenGLView alloc] initWithFrame:screenBounds];
    [self.view addSubview:_glView];
}

@end
