//
//  AppDelegate.h
//  Example1
//
//  Created by Michael Raber on 5/14/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INNControllerContext.h"
#import "UIViewController+INNControllerContext.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
  INNControllerContext *appControllerContext;
}

@property (strong, nonatomic) UIWindow *window;

@end
