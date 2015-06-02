//
//  ViewController.m
//  AutoLayoutDemo
//
//  Created by panda zheng on 15/4/18.
//  Copyright (c) 2015年 panda zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    //float width = [[UIScreen mainScreen] bounds].size.width;
    //float height = [[UIScreen mainScreen] bounds].size.height;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%f,%f",[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    NSLog(@"%f,%f",self.view.frame.size.width,self.view.frame.size.height);
    NSLog(@"%f,%f",[[UIScreen mainScreen] applicationFrame].size.width,[[UIScreen mainScreen] applicationFrame].size.height);

    /*
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width/2, height/2)];
    view1.backgroundColor = [UIColor redColor];
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    view2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:view2];*/
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
