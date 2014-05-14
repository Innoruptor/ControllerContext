//
//  ControllerContextTests.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/14/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "INNControllerContext.h"

@interface ControllerContextTests : XCTestCase

@end

@implementation ControllerContextTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)test1
{
  INNControllerContext *context = [[INNControllerContext alloc]init];
  
  [context setObject:@"Level 0 - Key 0" forKey:@"Key:0:0"];
  
  NSString *value = [context objectForKey:@"Key:0:0"];
  
  XCTAssertTrue([value isEqualToString:@"Level 0 - Key 0"], @"Retrieved key Key:0:0");
}

- (void)test2
{
  INNControllerContext *context1 = [[INNControllerContext alloc]init];
  
  [context1 setObject:@"Level 0 - Key 0" forKey:@"Key:0:0"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Level 1 - Key 0" forKey:@"Key:1:0"];
  
  XCTAssertTrue([[context2 objectForKey:@"Key:0:0"] isEqualToString:@"Level 0 - Key 0"], @"Retrieved key Key:0:0");
  
  XCTAssertTrue([[context2 objectForKey:@"Key:1:0"] isEqualToString:@"Level 1 - Key 0"], @"Retrieved key Key:1:0");
}

- (void)test3
{
  INNControllerContext *context1 = [[INNControllerContext alloc]init];
  
  [context1 setObject:@"Level 0 - Key 0" forKey:@"Key:0:0"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Level 1 - Key 0" forKey:@"Key:1:0"];
  
  INNControllerContext *context3 = [[INNControllerContext alloc]initWithInnerContext:context2];
  
  [context3 setObject:@"Level 2 - Key 0" forKey:@"Key:2:0"];
  
  INNControllerContext *context4 = [[INNControllerContext alloc]initWithInnerContext:context3];
  
  XCTAssertTrue([[context4 objectForKey:@"Key:0:0"] isEqualToString:@"Level 0 - Key 0"], @"Retrieved key Key:0:0");
  
  XCTAssertTrue([[context4 objectForKey:@"Key:1:0"] isEqualToString:@"Level 1 - Key 0"], @"Retrieved key Key:1:0");
  
  XCTAssertTrue([[context4 objectForKey:@"Key:2:0"] isEqualToString:@"Level 2 - Key 0"], @"Retrieved key Key:2:0");
}

- (void)test4
{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  [context1 setObject:@"Level 0 - Key 0" forKey:@"Key:0:0"];
  
  [context1 dumpToConsole];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Level 1 - Key 0" forKey:@"Key:1:0"];
  
  INNControllerContext *context3 = [[INNControllerContext alloc]initWithInnerContext:context2];
  
  [context3 setObject:@"Level 2 - Key 0" forKey:@"Key:2:0"];
  
  INNControllerContext *context4 = [[INNControllerContext alloc]initWithInnerContext:context3];
  
  [context4 dumpToConsole];
  
  XCTAssertTrue([[context4 objectForKey:@"Key:0:0" withContextName:@"base"] isEqualToString:@"Level 0 - Key 0"], @"Retrieved app key Key:0:0");
  
  XCTAssertNil([context4 objectForKey:@"Key:1:0" withContextName:@"base"], @"App key should return nil");
}

- (void)test5
{
  INNControllerContext *context1 = [[INNControllerContext alloc]init];
  
  [context1 setObject:@"Level 0 - Key 0" forKey:@"Key:0:0"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Level 1 - Key 0" forKey:@"Key:1:0"];
  
  INNControllerContext *context3 = [[INNControllerContext alloc]initWithInnerContext:context2];
  
  [context3 setObject:@"Level 2 - Key 0" forKey:@"Key:2:0"];
  
  [context3 dumpToConsole];
  
  [context3 removeObjectForKey:@"Key:2:0"];
  
  [context3 dumpToConsole];
  
  XCTAssertNil([context3 objectForKey:@"Key:2:0"], @"App key should return nil");
  
  [context3 removeObjectForKey:@"Key:1:0"];
  
  XCTAssertNil([context3 objectForKey:@"Key:1:0"], @"App key should return nil");
  
  [context3 removeObjectForKey:@"Key:0:0"];
  
  XCTAssertNil([context3 objectForKey:@"Key:0:0"], @"App key should return nil");
}

- (void)test6{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Base Level 0 - Key 0" forKey:@"Base Key:0:0" withContextName:@"base"];
  
  XCTAssertTrue([[context1 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0"], @"Retrieved base key Base Key:0:0");
  
  XCTAssertTrue([[context2 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0"], @"Retrieved base key Base Key:0:0");
  
  [context2 setObject:@"Base Level 0 - Key 0 - A" forKey:@"Base Key:0:0" withContextName:@"base"];
  
  XCTAssertTrue([[context1 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0 - A"], @"Retrieved base key Base Key:0:0");
  
  XCTAssertTrue([[context2 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0 - A"], @"Retrieved base key Base Key:0:0");
  
  [context2 removeObjectForKey:@"Base Key:0:0"];
  
  XCTAssertNil([context1 objectForKey:@"Base Key:0:0"], @"App key should return nil");
  
  XCTAssertNil([context2 objectForKey:@"Base Key:0:0"], @"App key should return nil");
}

- (void)test7{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"Base Level 0 - Key 0" forKey:@"Base Key:0:0" withContextName:@"base"];
  
  XCTAssertTrue([[context2 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0"], @"Retrieved base key Base Key:0:0");
  
  [context2 setObject:@"Base Level 0 - Key 0 - Changed" forKey:@"Base Key:0:0"];
  
  XCTAssertTrue([[context2 objectForKey:@"Base Key:0:0" withContextName:@"base"] isEqualToString:@"Base Level 0 - Key 0"], @"Retrieved base key Base Key:0:0");
  
  XCTAssertTrue([[context2 objectForKey:@"Base Key:0:0"] isEqualToString:@"Base Level 0 - Key 0 - Changed"], @"Retrieved base key Base Key:0:0");
}

- (void)test8{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  [context1 setObject:nil forKey:@"testNil"];
  
  XCTAssertNil([context1 objectForKey:@"testNil"], @"App key should return nil");
}

- (void)test9{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  [context1 setObject:nil forKey:@"testNil" withContextName:@"base"];
  
  XCTAssertNil([context1 objectForKey:@"testNil" withContextName:@"base"], @"App key should return nil");
}

- (void)test10{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  [context1 setObject:nil forKey:@"testNil" withContextName:@"base"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  XCTAssertNil([context2 objectForKey:@"testNil" withContextName:@"base"], @"App key should return nil");
}

- (void)test11{
  INNControllerContext *context1 = [[INNControllerContext alloc]initWithName:@"base"];
  
  [context1 setObject:@"V:0:0" forKey:@"K:0:0"];
  [context1 setObject:@"V:0:1" forKey:@"K:0:1"];
  
  INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
  
  [context2 setObject:@"V:1:0" forKey:@"K:1:0"];
  [context2 setObject:@"V:1:1" forKey:@"K:1:1"];
  
  INNControllerContext *context3 = [[INNControllerContext alloc]initWithInnerContext:context2];
  
  [context3 setObject:@"V:2:0" forKey:@"K:2:0"];
  [context3 setObject:@"V:2:1" forKey:@"K:2:1"];
  
  NSArray *allKeys = [context3 allKeys];
  
  XCTAssertTrue([allKeys containsObject:@"K:2:1"], @"key found");
  XCTAssertTrue([allKeys containsObject:@"K:2:0"], @"key found");
  XCTAssertTrue([allKeys containsObject:@"K:1:1"], @"key found");
  XCTAssertTrue([allKeys containsObject:@"K:1:0"], @"key found");
  XCTAssertTrue([allKeys containsObject:@"K:0:1"], @"key found");
  XCTAssertTrue([allKeys containsObject:@"K:0:0"], @"key found");
}


@end

