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

#ifdef USE_NON_NAMESPACED_INNCONTROLLERCONTEXT_CATEGORY

// NON-Namespaced Methods, only available if USE_NON_NAMESPACED_INNCONTROLLERCONTEXT_CATEGORY macro has been set

-(id) initWithContext:(INNControllerContext *)context
{
  return [self INN_initWithContext:context];
}

-(void) setContext:(INNControllerContext *)context
{
  [self INN_setContext:context];
}

-(INNControllerContext *)context
{
  return [self INN_context];
}

#endif

@end
