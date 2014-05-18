//
//  INNControllerContext.h
//  ControllerContextTest
//
//  Created by Michael Raber on 5/14/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BlockReference)(id object);

@interface INNControllerContext : NSObject{
  NSString *contextName;
  NSMutableDictionary *dictionary;
  INNControllerContext *innerContext;
  NSObject *lock;
  NSMutableDictionary *validPropertySetters;
  NSMutableDictionary *validPropertyGetters;
  NSMutableDictionary *callbackDictionary;
}

-(id) initWithName:(NSString *)name;
-(id) initWithInnerContext:(INNControllerContext *)controllerContext;
-(id) initWithName:(NSString *)name innerContext:(INNControllerContext *)controllerContext;

-(NSString *) name;

-(void) setObject:(id)object forKey:(NSString*)key withContextName:(NSString *)name;
-(id) objectForKey:(NSString *)key withContextName:(NSString *)name;
-(void) removeObjectForKey:(NSString *)key withContextName:(NSString *)name;

-(void) setObject:(id)object forKey:(NSString*)key;
-(id) objectForKey:(NSString *)key;
-(void) removeObjectForKey:(NSString *)key;

-(void) registerCallback:(BlockReference)block forKey:(NSString *)key withObject:(id)object;
-(void) removeCallbacksForObject:(id)object;
-(void) removeAllCallbacks;

-(NSArray *) allKeys;

-(void) dumpToConsole;

@end
