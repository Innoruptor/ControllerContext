//
//  ColorsVC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/11/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "ColorsVC.h"
#import "INNControllerContext.h"
#import "UIViewController+INNControllerContext.h"

@interface ColorsVC ()

@end

@implementation ColorsVC

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
      [self.INN_context setObject:[UIColor blackColor] forKey:@"newColor"];
      break;
      
    case 1:
      [self.INN_context setObject:[UIColor blueColor] forKey:@"newColor"];
      break;
      
    case 2:
      [self.INN_context setObject:[UIColor greenColor] forKey:@"newColor"];
      break;
      
    case 3:
      [self.INN_context setObject:[UIColor orangeColor] forKey:@"newColor"];
      break;
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

@end
