//
//  WorkflowSizeVC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/12/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "WorkflowSizeVC.h"
#import "INNControllerContext.h"
#import "UIViewController+INNControllerContext.h"
#import "ConfirmVC.h"

@interface WorkflowSizeVC ()

@end

@implementation WorkflowSizeVC

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.navigationController setNavigationBarHidden:NO];
  
  self.navigationItem.title = @"Size";
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sizeCell"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sizeCell" forIndexPath:indexPath];
  
  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = @"Small";
      break;
      
    case 1:
      cell.textLabel.text = @"Medium";
      break;
      
    case 2:
      cell.textLabel.text = @"Large";
      break;
      
    case 3:
      cell.textLabel.text = @"X-Large";
      break;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  switch (indexPath.row) {
    case 0:
      [self.INN_context setObject:@"Small" forKey:@"newSize"];
      break;
      
    case 1:
      [self.INN_context setObject:@"Medium" forKey:@"newSize"];
      break;
      
    case 2:
      [self.INN_context setObject:@"Large" forKey:@"newSize"];
      break;
      
    case 3:
      [self.INN_context setObject:@"X-Large" forKey:@"newSize"];
      break;
  }
  
  //
  // push SizeVC on the stack
  //
  ConfirmVC *vc = [[ConfirmVC alloc]INN_initWithContext:self.INN_context];
  
  [self.navigationController pushViewController:vc animated:YES];
}

@end
