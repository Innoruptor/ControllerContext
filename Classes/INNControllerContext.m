//
//  INNControllerContext.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/10/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "INNControllerContext.h"
#import <objc/runtime.h>

@interface INNControllerContextBlockReference : NSObject
@property (copy) BlockReference block;
@property (weak) id owner;
@end

@implementation INNControllerContextBlockReference
@end

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
    innerContext = controllerContext;
    callbackDictionary = [[NSMutableDictionary alloc]init];
    
    [self buildPropertyMap];
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
  
  //
  // execute any registered blocks
  //
  [self executeBlocksForKey:key];
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
  
  //
  // execute any registered blocks
  //
  [self executeBlocksForKey:key];
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

// -- manage callbacks

-(void) registerCallback:(BlockReference)block forKey:(NSString *)key withObject:(id)object{
  if((block==nil)||(key==nil)||(object==nil)){
    return;
  }
  
  @synchronized(lock){
    NSMutableArray *callbackList = callbackDictionary[key];
    
    if(callbackList==nil){
      callbackList = [[NSMutableArray alloc]init];
      
      [callbackDictionary setObject:callbackList forKey:key];
    }
    
    INNControllerContextBlockReference *blockReference = [[INNControllerContextBlockReference alloc]init];
    blockReference.block = block;
    blockReference.owner = object;
    
    [callbackList addObject:blockReference];
  }
}

-(void) removeAllCallbacks{
  @synchronized(lock){
    [callbackDictionary removeAllObjects];
  }
}

-(void) removeCallbacksForObject:(id)object{
  @synchronized(lock){
    for(NSString *key in callbackDictionary.allKeys){
      NSMutableArray *blockList = callbackDictionary[key];
      NSMutableArray *blockListCopy = blockList.copy;

      for(INNControllerContextBlockReference *blockReference in blockListCopy){
        if((blockReference.owner==nil)||(blockReference.owner==object)){
          //
          // remove block becuase we found a match or the owner was nil
          //
          [blockList removeObject:blockReference];
        }
      }
    }
  }
}

-(void) executeBlocksForKey:(NSString *)key{
  NSMutableArray *removeBlocks = nil;
  NSArray *blockList = nil;
  
  @synchronized(lock){
    NSMutableArray *blockListAll = callbackDictionary[key];
    
    
    if(blockListAll!=nil){
      //
      // copy the list
      //
      blockList = blockListAll.copy;
    }
  }
  
  if(blockList!=nil){
    for(INNControllerContextBlockReference *blockReference in blockList){
      if(blockReference.owner!=nil){
        //
        // execute block
        //
        blockReference.block(blockReference.owner);
      }
      else{
        if(removeBlocks==nil){
          removeBlocks = [[NSMutableArray alloc]init];
        }
        
        //
        // block had a nil reference to owner, mark for removal
        //
        [removeBlocks addObject:blockReference];
      }
    }
  }
  
  //
  // we have blocks with nil owner referencs, we will remove them
  //
  if(removeBlocks!=nil){
    @synchronized(lock){
      NSMutableArray *blockListAll = callbackDictionary[key];
      
      if(blockListAll!=nil){
        //
        // remove any blocks that now have nil references to the owner
        //
        for(INNControllerContextBlockReference *blockReference in removeBlocks){
          [blockListAll removeObject:blockReference];
        }
      }
    }
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

// manage properties backed by the internal dictionary

-(NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
  //
  // Objective-c already returns the correct signature for @optional property methods
  //
  NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
  
  //
  // if this is nil an "unrecognized selector sent to instance" exception is thrown
  //
  return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  NSString *selectorAsString = NSStringFromSelector(anInvocation.selector);
  
  NSString *setterProp = [validPropertySetters valueForKey:selectorAsString];
  if(setterProp){
    id value = [self getArgumentAtIndexAsObject:2 invocation:anInvocation];
    
    [self setInternalDictionaryWithObject:value forKey:setterProp];
    
    return;
  }
  
  NSString *getterProp = [validPropertyGetters valueForKey:selectorAsString];
  if(getterProp){
    [self setReturnValueForMethod:anInvocation returnValue:[self internalDictionaryObjectWithKey:getterProp]];
    
    return;
  }
  
  //
  // we don't know how to handle, the call below will throw an "unrecognized selector sent to instance" exception
  //
  [super forwardInvocation:anInvocation];
}

-(NSString *) uppercaseFirstCharacter:(NSString *)string{
  if(string==nil){
    return string;
  }
  
  return [NSString stringWithFormat:@"%@%@",[[string substringToIndex:1] uppercaseString],[string substringFromIndex:1]];
}

-(void) buildPropertyMap{
  validPropertySetters = [[NSMutableDictionary alloc]init];
  validPropertyGetters = [[NSMutableDictionary alloc]init];
  
  unsigned int outCount, i;
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for (i = 0; i < outCount; i++) {
    objc_property_t property = properties[i];
    
    NSString *propertyAsString = [NSString stringWithUTF8String:property_getName(property)];
    NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    
    NSArray *attrArray = [propertyAttributes componentsSeparatedByString:@","];
    
    NSInteger arraySize = [attrArray count];
    
    [validPropertySetters setObject:propertyAsString forKey:[NSString stringWithFormat:@"set%@:", [self uppercaseFirstCharacter:propertyAsString]]];
    [validPropertyGetters setObject:propertyAsString forKey:propertyAsString];
    
    if(arraySize>1){
      for(int i=1;i<arraySize;i++){
        if([attrArray[i] hasPrefix:@"S"]){
          //
          // override setter
          //
          [validPropertySetters setObject:propertyAsString forKey:[attrArray[i] substringFromIndex:1]];
        }
        else if([attrArray[i] hasPrefix:@"G"]){
          //
          // override getter
          //
          [validPropertyGetters setObject:propertyAsString forKey:[attrArray[i] substringFromIndex:1]];
        }
      }
    }
  }
}

- (id)getArgumentAtIndexAsObject:(int)argIndex invocation:(NSInvocation *)invocation{
  //
  // supported cislqCISLQfd@#
  //
  const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:argIndex];
  
  switch (argType[0])
	{
		case 'c':
    {
      char value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithChar:value];
		}
    case 'i':
    {
      NSInteger value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithInteger:value];
		}
    case 's':
    {
      short value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithShort:value];
		}
    case 'l':
    {
      long value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithLong:value];
		}
    case 'q':
    {
      long long value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithLongLong:value];
		}
    case 'C':
    {
      unsigned char value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithUnsignedChar:value];
		}
    case 'I':
    {
      unsigned int value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithUnsignedInt:value];
		}
    case 'S':
    {
      unsigned short value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithUnsignedShort:value];
		}
    case 'L':
    {
      unsigned long value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithUnsignedLong:value];
		}
    case 'Q':
    {
      unsigned long long value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithUnsignedLongLong:value];
		}
    case 'f':
    {
      float value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithFloat:value];
		}
    case 'd':
    {
      double value;
      [invocation getArgument:&value atIndex:argIndex];
      
      return [NSNumber numberWithDouble:value];
		}
		case '@':
		{
      //
      // this logic is required to have a strong reference to the object
      //
      void *tempValue;
			[invocation getArgument:&tempValue atIndex:argIndex];
      
      id value = (__bridge id)tempValue;
      
			return value;
		}
    case '#':
		{
      id value;
			[invocation getArgument:&value atIndex:argIndex];
      
			return value;
		}
  }
  
  return nil;
}

- (void)setReturnValueForMethod:(NSInvocation *)invocation returnValue:(id)returnValue{
  //
  // supported cislqCISLQfd@#
  //
  const char *returnTypeChar = [invocation.methodSignature methodReturnType];
  
  if((returnValue==nil)||([returnValue isKindOfClass:[NSNull class]])){
    return; // just don't set anything and we return a nil (is this safe?)
  }
  
  switch (returnTypeChar[0])
	{
		case 'c':
    {
      char value = [returnValue charValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'i':
    {
      NSInteger value = [returnValue intValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 's':
    {
      short value = [returnValue shortValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'l':
    {
      long value = [returnValue longValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'q':
    {
      long long value = [returnValue longLongValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'C':
    {
      unsigned char value = [returnValue unsignedCharValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'I':
    {
      unsigned int value = [returnValue unsignedIntValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'S':
    {
      unsigned short value = [returnValue unsignedShortValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'L':
    {
      unsigned long value = [returnValue unsignedLongValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'Q':
    {
      unsigned long long value = [returnValue unsignedLongLongValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'f':
    {
      float value = [returnValue floatValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case 'd':
    {
      double value = [returnValue doubleValue];
      
      [invocation setReturnValue:&value];
      
      break;
		}
    case '@':
    {
      [invocation setReturnValue:&returnValue];
      
      break;
    }
    case '#':
    {
      [invocation setReturnValue:&returnValue];
      
      break;
		}
  }
}

@end

//
// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
//

