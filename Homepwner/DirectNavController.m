//
//  DirectNavController.m
//  Homepwner
//
//  Created by Sen on 9/16/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "DirectNavController.h"

@interface DirectNavController ()

@end

@implementation DirectNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回设备支持方向,子类化
- (UIInterfaceOrientationMask)supportedInterfaceOrientations //是的,要个独特的类型
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) { //判断是Pad还是Phone
        NSLog(@"是Pad");
        //        return UIInterfaceOrientationMaskAll; //支持全部旋转
    } else {
        NSLog(@"是Phone");
        //        return UIInterfaceOrientationMaskAllButUpsideDown; //支持除了倒置的所有旋转
    }
    return UIInterfaceOrientationMaskAll; //全部好了...
//    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight; //返回左和右...
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
