//
//  WorkflowColorsVC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/12/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "WorkflowColorsVC.h"
#import "WorkflowSizeVC.h"

@interface WorkflowColorsVC ()

@end

@implementation WorkflowColorsVC

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
  
  //
  // create a new INNControllerContext that only lives from this View Controller going forward
  //
  workflowContext = [[INNControllerContext alloc] initWithInnerContext:self.INN_context];
  
  [self.navigationController setNavigationBarHidden:NO];
  
  self.navigationItem.title = @"Color";
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"colorCell"];
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
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
  
  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = @"Black";
      cell.textLabel.textColor = [UIColor blackColor];
      break;
      
    case 1:
      cell.textLabel.text = @"Blue";
      cell.textLabel.textColor = [UIColor blueColor];
      break;
      
    case 2:
      cell.textLabel.text = @"Green";
      cell.textLabel.textColor = [UIColor greenColor];
      break;
      
    case 3:
      cell.textLabel.text = @"Orange";
      cell.textLabel.textColor = [UIColor orangeColor];
      break;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  switch (indexPath.row) {
    case 0:
      [workflowContext setObject:@"Black" forKey:@"newColor"];
      break;
      
    case 1:
      [workflowContext setObject:@"Blue" forKey:@"newColor"];
      break;
      
    case 2:
      [workflowContext setObject:@"Green" forKey:@"newColor"];
      break;
      
    case 3:
      [workflowContext setObject:@"Orange" forKey:@"newColor"];
      break;
  }
  
  //
  // push SizeVC on the stack, send the workflow context
  //
  WorkflowSizeVC *vc = [[WorkflowSizeVC alloc]INN_initWithContext:workflowContext];
  
  [self.navigationController pushViewController:vc animated:YES];
}

@end
