//
//  MainViewVC.m
//  ControllerContextTest
//
//  Created by Michael Raber on 5/10/14.
//  Copyright (c) 2014 Innoruptor. All rights reserved.
//

#import "MainViewVC.h"
#import "UIViewController+INNControllerContext.h"
#import "ColorsVC.h"
#import "SizeVC.h"
#import "WorkflowColorsVC.h"
#import "Tab1VC.h"
#import "Tab2VC.h"
#import "Tab3VC.h"
#import "QuantityVC.h"

@interface MainViewVC ()

@end

@implementation MainViewVC

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
  
  [self.navigationController setNavigationBarHidden:YES];
  
  self.tabBarController.title = @"Examples";
  
  workflowColor = @"Unknown Color";
  workflowSize = @"Unknown Size";
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"theCell"];
  
  color = [UIColor blackColor];
  size = @"Choose size";
  
  INNControllerContext *context = [self INN_context];
  
  [context registerCallback:^(id object) {
    
    NSLog(@"callback with Object: %@", object);
    
    [object callInternalMethod];
    
  } forKey:@"testCallback" withObject:self];
  
  [context setObject:@"test data" forKey:@"testCallback"];
  
  [context removeCallbacksForObject:self];
  
  [context setObject:@"test data 2" forKey:@"testCallback"];
  
  NSLog(@"next line");
}

-(void) callInternalMethod{
  NSLog(@"cool");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(section==0){
    return 2;
  }
  else if(section==0){
    return 1;
  }
  else{
    return 1;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  UILabel *label = [[UILabel alloc]init];
  label.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
  label.textColor = [UIColor whiteColor];

  if(section==0){
    label.text = @" Single Screen Examples";
    
    return label;
  }
  else if(section==1){
    label.text = @" Single Screen Example";
    
    return label;
  }
  else if(section==2){
    label.text = @" Shared Data Example";
    
    return label;
  }
  else{
    label.text = @" Context with Properties Example";
    
    return label;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"theCell" forIndexPath:indexPath];
  
    if(indexPath.section==0){
      if(indexPath.row==0){
        cell.textLabel.text = @"Color";
        cell.textLabel.textColor = color;
      }
      else if(indexPath.row==1){
        cell.textLabel.text = size;
        cell.textLabel.textColor = [UIColor blackColor];
      }
    }
    else if(indexPath.section==1){
      if(indexPath.row==0){
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", workflowColor, workflowSize]];
        [string addAttribute:NSForegroundColorAttributeName value:[self getColor:workflowColor] range:NSMakeRange(0,[workflowColor length])];
        
        cell.textLabel.attributedText = string;
      }
    }
    else if(indexPath.section==2){
      if(indexPath.row==0){
        cell.textLabel.text = [NSString stringWithFormat:@"Tab selected [%@]",
                               tabSelected==nil ? @"None" : tabSelected];
        cell.textLabel.textColor = [UIColor blackColor];
      }
    }
    else if(indexPath.section==3){
      if(indexPath.row==0){
        cell.textLabel.text = [NSString stringWithFormat:@"Quantity: %i", quantity];
        cell.textLabel.textColor = [UIColor blackColor];
      }
    }
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  if(indexPath.section==0){
    if(indexPath.row==0){
      ColorsVC *vc = [[ColorsVC alloc]init];
  
      colorContext = [[INNControllerContext alloc] initWithInnerContext:self.INN_context];
      [vc INN_setContext:colorContext];
  
      [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row==1){
      SizeVC *vc = [[SizeVC alloc]init];
    
      sizeContext = [[INNControllerContext alloc] initWithInnerContext:self.INN_context];
      [vc INN_setContext:sizeContext];
    
      [self.navigationController pushViewController:vc animated:YES];
    }
  }
  else if(indexPath.section==1){
    if(indexPath.row==0){
      WorkflowColorsVC *vc = [[WorkflowColorsVC alloc]init];
    
      workflowContext = [[INNControllerContext alloc] initWithName:@"workflow" innerContext:self.INN_context];
      
      //
      // pass the workflowContext to the next view controller
      //
      [vc INN_setContext:workflowContext];
    
      [self.navigationController pushViewController:vc animated:YES];
    }
  }
  else if(indexPath.section==2){
    if(indexPath.row==0){
      Tab1VC *tab1VC = [[Tab1VC alloc] init];
      Tab2VC *tab2VC = [[Tab2VC alloc] init];
      Tab3VC *tab3VC = [[Tab3VC alloc] init];
      
      sharedTabContext = [[INNControllerContext alloc] initWithName:@"sharedTab" innerContext:self.INN_context];
      
      //
      // set current value stored in tabSelected
      //
      [sharedTabContext setObject:tabSelected forKey:@"currentTab"];

      [tab1VC INN_setContext:sharedTabContext];
      [tab2VC INN_setContext:sharedTabContext];
      [tab3VC INN_setContext:sharedTabContext];
      
      UITabBarController *tabVC = [[UITabBarController alloc]init];
      tabVC.viewControllers  = [NSArray arrayWithObjects:tab1VC,tab2VC,tab3VC,nil];
      tabVC.delegate = self;
      
      [self presentViewController:tabVC animated:YES completion:nil];
    }
  }
  else if(indexPath.section==3){
    if(indexPath.row==0){
      QuantityVC *vc = [[QuantityVC alloc]init];
      
      quantityContext = [[QuantityContext alloc] initWithName:@"quantity" innerContext:self.INN_context];
      
      //
      // pass the quantityContext to the next view controller
      //
      [vc INN_setContext:quantityContext];
      
      [self.navigationController pushViewController:vc animated:YES];
    }
  }
}

-(void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self.navigationController setNavigationBarHidden:YES];
  
  //
  // if newColor was set we can apply the color to the 
  //
  if(colorContext!=nil){
    NSLog(@"Returned from color, ControllerContext: %@", [self class]);
    [colorContext dumpToConsole];
    
    UIColor *newColor = [colorContext objectForKey:@"newColor"];
    if(newColor!=nil){
      color = newColor;
      
      [self.tableView reloadData];
    }
    
    colorContext = nil;
  }
  
  if(sizeContext!=nil){
    NSLog(@"Returned from size, ControllerContext: %@", [self class]);
    [sizeContext dumpToConsole];
    
    NSString *newSize = [sizeContext objectForKey:@"newSize"];
    
    if(newSize!=nil){
      size = newSize;
      
      [self.tableView reloadData];
    }
    
    sizeContext = nil;
  }
  
  if(workflowContext!=nil){
    NSLog(@"Returned from workflow, ControllerContext: %@", [self class]);
    [workflowContext dumpToConsole];
    
    workflowColor = [workflowContext objectForKey:@"workflowColor"];
    workflowSize = [workflowContext objectForKey:@"workflowSize"];
    
    if((workflowColor!=nil)&&(workflowSize!=nil)){
      [self.tableView reloadData];
    }
    
    workflowContext = nil;
  }
  
  if(sharedTabContext!=nil){
    NSLog(@"Returned from sharedTab, ControllerContext: %@", [self class]);
    [sharedTabContext dumpToConsole];
    
    NSString *newTabSelected = [sharedTabContext objectForKey:@"currentTab"];
    
    if(newTabSelected!=nil){
      tabSelected = newTabSelected;
      
      [self.tableView reloadData];
    }
  }
  
  if(quantityContext!=nil){
    quantity = quantityContext.quantity;
    
    [self.tableView reloadData];
  }
}

-(UIColor *) getColor:(NSString *)colorName{
  if(colorName!=nil){
    if([colorName isEqualToString:@"Blue"]){
      return [UIColor blueColor];
    }
    else if([colorName isEqualToString:@"Green"]){
      return [UIColor greenColor];
    }
    else if([colorName isEqualToString:@"Orange"]){
      return [UIColor orangeColor];
    }
  }
  
  return [UIColor blackColor];
}

@end
