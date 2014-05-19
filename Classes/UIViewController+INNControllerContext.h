//
//  UIViewController+INNControllerContext.h
//  ControllerContextTest
//
//  Created by Michael Raber on 5/14/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INNControllerContext.h"

@interface UIViewController (INNControllerContext)

-(id) INN_initWithContext:(INNControllerContext *)context;
-(void) INN_setContext:(INNControllerContext *)context;
-(INNControllerContext *)INN_context;

#ifdef USE_NON_NAMESPACED_INNCONTROLLERCONTEXT_CATEGORY

-(id) initWithContext:(INNControllerContext *)context;
-(void) setContext:(INNControllerContext *)context;
-(INNControllerContext *)context;

#endif

@end
