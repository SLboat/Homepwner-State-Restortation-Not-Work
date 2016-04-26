//
//  AppDelegate.m
//  Homepwner
//
//  Created by Sen on 6/15/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemsViewController.h"
#import "DirectNavController.h"
#import "ItemStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


//为了恢复状态,在即将启动完成之前,进行窗口准备...因为启动完毕后就完蛋了?或者说整个解码的过程从这里就已经开始了
-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //等等,先不必激活..
    return YES; //好了,完事了.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //这里是一个回环,因为self.window已经在willFinishLauching的时候已经准备完毕了,缺少的是让它成为唯一根窗口,而这个过程中间应该接管的状态恢复机制,但接管失败,可以认为恢复无效,这里需要的是重建根视图.
    if (!self.window.rootViewController) { //没有根试图,恢复失败?
        
        // Create a ItemsViewController
        ItemsViewController *itemsViewController = [[ItemsViewController alloc] init];// 或者new配对,哈!
        
        // Create an instance of a UINavigationController
        // its stack contains only itemsViewController..
        DirectNavController *navController = [[DirectNavController alloc] initWithRootViewController:itemsViewController]; //赋予子类进去使用...
        
        //Give the navitation controller a restoration identifier that is same name as the class
        navController.restorationIdentifier = NSStringFromClass(navController.class);
        
        // Place navigation controller's view in the window hierarchy
        self.window.rootViewController = itemsViewController; //根是导航者
        
        //准备完毕        
    }
    //一定要声张窗口,哈!
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /* 上面很多的注释,描述着应该适合这里干什么,释放共享资源,保存应用状态... */

    BOOL sucess = [[ItemStore sharedStore] saveChanges];

    if (sucess) {
        NSLog(@"保存了所有的BNRItem");
    } else {
        NSLog(@"没法儿保存任何BNRItem");
    }

    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

#pragma mark -
#pragma mark 保存应用
///是否保存应用状态
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}

///是否恢复应用状态
-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return YES;
}

#pragma mark -
#pragma mark 没有恢复类的恢复-导航栏啥的
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    //建造一个新的导航控制器
    UIViewController *vc = [[DirectNavController alloc]init]; //如果是UINavigationController,就得报错了,因为是它的子类,这里将恢复完全失败,一片空白
    
    //路径数组里的最后一个玩意是给这个视图控制器的恢复id
    vc.restorationIdentifier = [identifierComponents lastObject];
    
    //如果只有一个路径,那就是根玩意
    if ([identifierComponents count] == 1) {
        self.window.rootViewController = vc; //根于这里
    }
    
    return vc;
}



@end
