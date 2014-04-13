//
//  AppDelegate.m
//  VSHorizontalDateSlider
//
//  Created by Vincent Nguyen on 13/4/14.
//  Copyright (c) 2014 nvson28. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:NSStringFromClass([MainViewController class]) bundle:nil];
    self.window.rootViewController = mainVC;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
