//
//  Tab3VC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/12/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "Tab3VC.h"
#import "INNControllerContext.h"
#import "UIViewController+INNControllerContext.h"

static NSString *TAB_NAME = @"Tab 3";

@interface Tab3VC ()

@end

@implementation Tab3VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = TAB_NAME;
    self.tabBarItem.image = [UIImage imageNamed:@"tab_icon.png"];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  tabNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 60, 260, 30)];
  tabNameLabel.textAlignment = NSTextAlignmentCenter;
  tabNameLabel.text = @"You are in Tab 3";
  [self.view addSubview:tabNameLabel];
  
  lastTabLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 160, 260, 30)];
  lastTabLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:lastTabLabel];
  
  button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setTitle:@"Select this tab" forState:UIControlStateNormal];
  button.backgroundColor = [UIColor blueColor];
  [button addTarget:self action:@selector(tabSelectedButton) forControlEvents:UIControlEventTouchUpInside];
  button.frame = CGRectMake(30, 200, 260, 40);
  [self.view addSubview:button];
  
  doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [doneButton setTitle:@"Done" forState:UIControlStateNormal];
  doneButton.backgroundColor = [UIColor lightGrayColor];
  [doneButton addTarget:self action:@selector(doneButtonSelected) forControlEvents:UIControlEventTouchUpInside];
  doneButton.frame = CGRectMake(30, 350, 260, 40);
  [self.view addSubview:doneButton];
}

-(void) viewWillAppear:(BOOL)animated{
  INNControllerContext *controllerContext = [self INN_context];
  
  NSString *currentTab = [controllerContext objectForKey:@"currentTab"];
  
  if(currentTab==nil){
    lastTabLabel.text = @"[no tab selected yet]";
  }
  else{
    lastTabLabel.text = currentTab;
  }
}

-(void) tabSelectedButton{
  INNControllerContext *controllerContext = [self INN_context];
  
  [controllerContext setObject:TAB_NAME forKey:@"currentTab"];
  lastTabLabel.text = TAB_NAME;
}

-(void) doneButtonSelected{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
  self.view.backgroundColor = [UIColor whiteColor];
}

@end
