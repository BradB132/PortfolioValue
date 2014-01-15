//
//  PVAddController.m
//  PortfolioValue
//
//  Created by Brad Bambara on 1/14/14.
//  Copyright (c) 2014 Brad Bambara. All rights reserved.
//

#import "PVAddController.h"
#import "UserStock.h"
#import "PVUserStockManager.h"

@interface PVAddController ()

@property (weak, nonatomic) IBOutlet UITextField *symbolName;
@property (weak, nonatomic) IBOutlet UITextField *numberOfShares;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@end

@implementation PVAddController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_addBtn.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedAddBtn:(UIButton *)sender
{
	UserStock* newStock = [[UserStock alloc] init];
	newStock.symbolName = _symbolName.text;
	newStock.sharesOwned = [_numberOfShares.text floatValue];
	
	[[PVUserStockManager sharedInstance] addUserStock:newStock];
	[[PVUserStockManager sharedInstance] refreshPriceData];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate (et al)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}

- (IBAction)didUpdateTextField:(UITextField *)sender
{
	BOOL enabled = ([_symbolName.text length] > 0 &&
					[_numberOfShares.text length] > 0);
	
	_addBtn.hidden = !enabled;
}

@end
