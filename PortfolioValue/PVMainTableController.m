//
//  PVMainTableController.m
//  PortfolioValue
//
//  Created by Brad Bambara on 1/13/14.
//  Copyright (c) 2014 Brad Bambara. All rights reserved.
//

#import "PVMainTableController.h"
#import "PVUserStockManager.h"
#import "UserStock.h"

@interface PVMainTableController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSNumberFormatter* moneyFormatter;

@end

@implementation PVMainTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.moneyFormatter = [[NSNumberFormatter alloc] init];
	[_moneyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(performDataRefresh)
												 name:UIApplicationDidBecomeActiveNotification
											   object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(dataDidUpdate)
												 name:kPVUserStockManagerFinishedPricesUpdateNotification
											   object:NULL];
	
	[self performDataRefresh];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)performDataRefresh
{
	[_activityIndicator startAnimating];
	[_activityIndicator setHidden:NO];
	[[PVUserStockManager sharedInstance] refreshPriceData];
}

-(void)dataDidUpdate
{
	[_activityIndicator setHidden:YES];
	[_activityIndicator stopAnimating];
	[_tableView reloadData];
}

-(IBAction)backToMainTable:(UIStoryboardSegue*)segue
{
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return 1;
		case 1:
			return [[PVUserStockManager sharedInstance].userStocks count];
		default:
			return 0;
	}
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* saveCellID = @"PVMainTableControllerCell";
	UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:saveCellID forIndexPath:indexPath];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	switch(indexPath.section)
	{
		case 0:
		{
			float total = 0.0f;
			for(UserStock* userStock in [PVUserStockManager sharedInstance].userStocks)
				total += userStock.price*userStock.sharesOwned;
			
			NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterNoStyle];
			[formatter setTimeStyle:NSDateFormatterShortStyle];
			[formatter setLocale:[NSLocale currentLocale]];
			
			cell.textLabel.text = [NSString stringWithFormat:@"TOTAL VALUE - %@", [formatter stringFromDate:[[PVUserStockManager sharedInstance] lastUpdated]]];
			cell.detailTextLabel.text = [_moneyFormatter stringFromNumber:[NSNumber numberWithFloat:total]];
		}
			break;
		case 1:
		{
			UserStock* userStock = [PVUserStockManager sharedInstance].userStocks[indexPath.row];
			cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", userStock.symbolName, userStock.stockName];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%g * %@ = %@", userStock.sharesOwned, [_moneyFormatter stringFromNumber:[NSNumber numberWithFloat:userStock.price]], [_moneyFormatter stringFromNumber:[NSNumber numberWithFloat:userStock.sharesOwned*userStock.price]]];
		}
			break;
		default:
			break;
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 0 && editingStyle == UITableViewCellEditingStyleDelete)
	{
		//remove the model object from the list
		[[PVUserStockManager sharedInstance] removeUserStock:[PVUserStockManager sharedInstance].userStocks[indexPath.row]];
		
		//show an animation for the delete
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView endUpdates];
		
		//refresh the data
		[_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

@end
