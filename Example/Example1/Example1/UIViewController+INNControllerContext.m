//
//  UIViewController+INNControllerContext.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/10/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "UIViewController+INNControllerContext.h"
#import "INNControllerContext.h"
#import <objc/runtime.h>

static char const * const INNControllerContextKey = "INNControllerContextKey";

@implementation UIViewController (INNControllerContext)

-(id) INN_initWithContext:(INNControllerContext *)context
{
  id _self = [self init];
  
  [self INN_setContext:context];
  
  return _self;
}

-(void) INN_setContext:(INNControllerContext *)context
{
  objc_setAssociatedObject(self, INNControllerContextKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(INNControllerContext *)INN_context
{
  return objc_getAssociatedObject(self, INNControllerContextKey);
}


@end
