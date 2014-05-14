//
//  INNControllerContext.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/10/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "INNControllerContext.h"

@interface INNControllerContext ()
-(void) retrieveAllKeys:(NSMutableArray *)allKeys;
@end

@implementation INNControllerContext

// -- init methods --

- (id)init
{
  return [self initWithName:nil innerContext:nil];
}

-(id) initWithName:(NSString *)name{
  return [self initWithName:name innerContext:nil];
}

- (id)initWithInnerContext:(INNControllerContext *)controllerContext
{
  return [self initWithName:nil innerContext:controllerContext];
}

-(id) initWithName:(NSString *)name innerContext:(INNControllerContext *)controllerContext{
  lock = [[NSObject alloc]init];
  
  if (self = [super init]) {
    contextName = name;
    dictionary = [[NSMutableDictionary alloc]init];
    innerContext = controllerContext;;
  }
  return self;
}

// -- name method --

-(NSString *) name{
  return contextName;
}

// -- Manage data with a named ControllerContext --

-(void) setObject:(id)object forKey:(NSString*)key withContextName:(NSString *)name{
  if(key==nil){
    return;
  }
  
  INNControllerContext *contextWithName = [self controllerContextWithName:name];
  
  if(contextWithName!=nil){
    [contextWithName setInternalDictionaryWithObject:object forKey:key];
  }
}

-(id) objectForKey:(NSString *)key withContextName:(NSString *)name{
  if(key==nil){
    return nil;
  }
  
  INNControllerContext *contextWithName = [self controllerContextWithName:name];
  
  if(contextWithName==nil){
    return nil;
  }
  
  return [contextWithName internalDictionaryObjectWithKey:key];
}

-(void) removeObjectForKey:(NSString *)key withContextName:(NSString *)name{
  if(key==nil){
    return;
  }
  
  INNControllerContext *contextWithName = [self controllerContextWithName:name];
  
  if(contextWithName!=nil){
    [contextWithName removeInternalDictionaryObjectForKey:key];
  }
}

// -- Manage data --

-(void) setObject:(id)object forKey:(NSString*)key
{
  if(key==nil){
    return;
  }
  
  [self setInternalDictionaryWithObject:object forKey:key];
}

-(id) objectForKey:(NSString *)key
{
  if(key==nil){
    return nil;
  }
  
  id object = nil;
  
  @synchronized(lock){
    object = [dictionary objectForKey:key];
  }

  if((object!=nil)&&(object==[NSNull null])){
    //
    // NSNull was explicitly set as the value so we need to return nil
    //
    
    return nil;
  }
  
  if(object==nil){
    object = [innerContext objectForKey:key];
  }
  
  return object;
}

-(void) removeObjectForKey:(NSString *)key{
  if(key==nil){
    return;
  }
  
  INNControllerContext *contextWithKey = [self controllerContextWithKey:key];
  
  if(contextWithKey!=nil){
    [contextWithKey removeInternalDictionaryObjectForKey:key];
  }
}

// -- other methods --

-(NSArray *) allKeys{
  NSMutableArray *allKeysArray = @[].mutableCopy;
  
  [self retrieveAllKeys:allKeysArray];
  
  return allKeysArray;
}

-(void) retrieveAllKeys:(NSMutableArray *)allKeys{
  [allKeys addObjectsFromArray:dictionary.allKeys];
  
  if(innerContext!=nil){
    [innerContext retrieveAllKeys:allKeys];
  }
}

-(void) dumpToConsole{
  NSLog(@"---------------");
  [self dumpToConsole:[self countLayers:0]-1];
  NSLog(@"---------------");
}

// -- private methods --

-(NSInteger) countLayers:(NSInteger)count{
  count = count +1;
  
  if(innerContext!=nil){
    return[innerContext countLayers:count];
  }
  else{
    return count;
  }
}

-(void) dumpToConsole:(NSInteger)level{
  NSLog(@"%i:--- %@ ---", level, self.name);
  
  NSMutableDictionary *cloneDictionary = [[NSMutableDictionary alloc]init];
  
  @synchronized(lock){
    [cloneDictionary addEntriesFromDictionary:dictionary];
  }
  
  if([dictionary count]>0){
    for(NSString *key in dictionary){
      NSLog(@"%i:%@ = %@", level, key, dictionary[key]);
    }
  }
  else{
    NSLog(@"%i:%@", level, @"[empty]");
  }
  
  level--;
  
  if(innerContext!=nil){
    [innerContext dumpToConsole:level];
  }
}

-(BOOL) hasKeyLocally:(NSString *)key{
  @synchronized(lock){
    return [dictionary objectForKey:key]!=nil;
  }
}

-(INNControllerContext *) baseControllerContext{
  if(innerContext!=nil){
    return [innerContext baseControllerContext];
  }
  
  return self;
}

-(INNControllerContext *) controllerContextWithName:(NSString *)name{
  if(name==nil){
    return nil;
  }
  
  if((self.name!=nil)&&([name isEqualToString:contextName])){
    return self;
  }
    
  if(innerContext!=nil){
    return [innerContext controllerContextWithName:name];
  }
  
  return nil;
}

-(INNControllerContext *) controllerContextWithKey:(NSString *)key{
  if([self hasKeyLocally:key]){
    return self;
  }
  
  if(innerContext!=nil){
    return [innerContext controllerContextWithKey:key];
  }
  
  return nil;
}

-(void) setInternalDictionaryWithObject:(id)object forKey:(NSString*)key
{
  if(object==nil){
    object = [NSNull null];
  }

  @synchronized(lock){
    [dictionary setObject:object forKey:key];
  }
}

-(id) internalDictionaryObjectWithKey:(id)key
{
  id object=nil;
  
  @synchronized(lock){
    object = [dictionary objectForKey:key];
  }
  
  if((object!=nil)&&(object==[NSNull null])){
    object = nil;
  }
  
  return object;
}

-(void) removeInternalDictionaryObjectForKey:(NSString*)key
{
  @synchronized(lock){
    [dictionary removeObjectForKey:key];
  }
}

@end
