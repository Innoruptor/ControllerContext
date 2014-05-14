//
//  ConfirmVC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/12/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "ConfirmVC.h"
#import "INNControllerContext.h"
#import "UIViewController+INNControllerContext.h"


@interface ConfirmVC ()

@end

@implementation ConfirmVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.navigationController setNavigationBarHidden:NO];
  
  self.navigationItem.title = @"Select choices";
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  //
  // setup UI views
  //
  
  colorLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 100, 260, 30)];
  colorLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:colorLabel];
  
  sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 140, 260, 30)];
  sizeLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:sizeLabel];
  
  timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [timeButton setTitle:@"Add to Cart" forState:UIControlStateNormal];
  timeButton.backgroundColor = [UIColor blueColor];
  [timeButton addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
  timeButton.frame = CGRectMake(30, 180, 260, 40);
  [self.view addSubview:timeButton];
  
  //
  // retrieve values passed through the workflow
  //
  NSString *newColor = [self.INN_context objectForKey:@"newColor"];
  NSString *newSize = [self.INN_context objectForKey:@"newSize"];
  
  colorLabel.text = newColor;
  sizeLabel.text = newSize;
}

-(void) addToCart{
  //
  // retrieve values passed through the workflow
  //
  NSString *newColor = [self.INN_context objectForKey:@"newColor"];
  NSString *newSize = [self.INN_context objectForKey:@"newSize"];
  
  //
  // assign values to context named "workflow"
  //
  [self.INN_context setObject:newColor forKey:@"workflowColor" withContextName:@"workflow"];
  [self.INN_context setObject:newSize forKey:@"workflowSize" withContextName:@"workflow"];
  
  NSLog(@"ControllerContext: %@", [self class]);
  [self.INN_context dumpToConsole];
  
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
