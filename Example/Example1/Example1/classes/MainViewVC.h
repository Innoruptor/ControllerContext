//
//  MainViewVC.h
//  ControllerContextTest
//
//  Created by Michael Raber on 5/14/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INNControllerContext.h"

@interface MainViewVC : UITableViewController<UITabBarControllerDelegate>{
  INNControllerContext *colorContext;
  INNControllerContext *sizeContext;
  INNControllerContext *workflowContext;
  INNControllerContext *sharedTabContext;
  UIColor *color;
  NSString *size;
  NSString *workflowColor;
  NSString *workflowSize;
  NSString *tabSelected;
}

@end
