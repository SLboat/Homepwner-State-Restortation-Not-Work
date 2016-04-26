//
//  ImageViewController.m
//  Homepwner
//
//  Created by Sen on 10/22/15.
//  Copyright © 2015 SLboat. All rights reserved.
//

#import "ImageViewController.h"

@implementation ImageViewController

- (void)loadView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit; //缩放对应
    self.view = imageView;//唯一视图
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //必须把它试图安排给角色,使得编译器理解它可以发送图片的消息-指针转换
    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = self.image;

 }

@end
