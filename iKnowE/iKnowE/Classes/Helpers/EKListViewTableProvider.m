//
//  EKListViewTableProvider.m
//  iKnowE
//
//  Created by Evgeny Karkan on 22.09.13.
//  Copyright (c) 2013 EvgenyKarkan. All rights reserved.
//

#import "EKListViewTableProvider.h"
#import "EKAdditiveDescription.h"
#import "EKDetailViewController.h"
#import "EKAppDelegate.h"
#import "EKListViewController.h"
#import "EKCoreDataProvider.h"
#import "Additive.h"
#import "EKTableSectionHeaderView.h"
#import "EKSettingsProvider.h"

static NSString * const kITReuseIdentifier = @"defaultCell";

@interface EKListViewTableProvider ()

@property (nonatomic, strong) EKAppDelegate *appDelegate;
@property (nonatomic, strong) EKTableSectionHeaderView *headerView;

@end


@implementation EKListViewTableProvider;

#pragma mark - Designated initializer

- (id)initWithDelegate:(id <EKListViewTableDelegate> )delegate
{
	self = [super init];
	if (self) {
		self.delegate = delegate;
		self.usualData = [[NSArray alloc] init];
		self.searchPlistData = [[NSMutableArray alloc] init];
        self.searchCoreDataData = [[NSMutableArray alloc] init];
		self.appDelegate = (EKAppDelegate *)[[UIApplication sharedApplication] delegate];
	}
	
	return self;
}

#pragma mark - Tableview API

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger number = 0;
    
    if ([[[EKCoreDataProvider sharedInstance] fetchedEntitiesForEntityName:kEKEntityName] count] > 0) {
        number = 2;
    }
    else {
        number = 1;
    }
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView numberOfSections] == 2) {
        if (section == 1) {
            self.headerView = [[EKTableSectionHeaderView alloc] initWithTitle:@"DEFAULT DATA"];
            [self.headerView addTarget:self addAction:@selector(scrollToSectionTop)];
        }
        else {
            self.headerView = [[EKTableSectionHeaderView alloc] initWithTitle:@"USER DATA"];
        }
    }
    else {
        self.headerView = [[EKTableSectionHeaderView alloc] initWithTitle:@"DEFAULT DATA"];
    }

    return self.headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger number = 0;
    
	if ([tableView numberOfSections] == 1) {
		if (self.search == YES) {
			number = [self.searchPlistData count];
		}
		else {
			number = [self.usualData count];
		}
	}
	else {
		if (section == 1) {
			if (self.search == YES) {
				number = [self.searchPlistData count];
			}
			else {
				number = [self.usualData count];
			}
		}
		else {
			if (self.search == YES) {
				number = [self.searchCoreDataData count];
			}
			else {
				number = [[[EKCoreDataProvider sharedInstance] fetchedEntitiesForEntityName:kEKEntityName] count];
			}
		}
	}
    
	return number;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0.121569 green:0.329412 blue:0.384314 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kITReuseIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kITReuseIdentifier];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:0.062745 green:0.215686 blue:0.274510 alpha:1];
        cell.selectedBackgroundView = selectionColor;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:@"CicleSemi" size:25.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:0.419608 green:0.937255 blue:0.960784 alpha:1];
    }
	if ([tableView numberOfSections] == 1) {
		if (self.search) {
			NSAssert([self.searchPlistData count] > 0, @"SearchPlistData array should have at least one object");
			cell.textLabel.text = ((EKAdditiveDescription *)self.searchPlistData[indexPath.row]).code;
		}
		else {
			cell.textLabel.text = ((EKAdditiveDescription *)self.usualData[indexPath.row]).code;
		}
	}
	else {
		if (self.search) {
			if (indexPath.section == 0) {
				NSAssert([self.searchCoreDataData count] > 0, @"SearchCoreDataData array should have at least one object");
				cell.textLabel.text = ((Additive *)self.searchCoreDataData[indexPath.row]).ecode;
			}
			else {
				NSAssert([self.searchPlistData count] > 0, @"SearchPlistData array should have at least one object");
				cell.textLabel.text = ((EKAdditiveDescription *)self.searchPlistData[indexPath.row]).code;
			}
		}
		else {
			if (indexPath.section == 0) {
				NSAssert([[[EKCoreDataProvider sharedInstance] fetchedEntitiesForEntityName:kEKEntityName] count] > 0, @"Fetched array should have at least one entity");
				cell.textLabel.text = ((Additive *)[[EKCoreDataProvider sharedInstance] fetchedEntitiesForEntityName:kEKEntityName][indexPath.row]).ecode;
			}
			else {
				cell.textLabel.text = ((EKAdditiveDescription *)self.usualData[indexPath.row]).code;
			}
		}
	}
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 58.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.delegate = self.appDelegate.splitViewController.viewControllers[1];
	if (self.delegate) {
		if ([tableView numberOfSections] == 1) {
			if (self.search) {
				[self.delegate cellDidPressWithData:self.searchPlistData withIndexPath:indexPath useCoreData:NO];
			}
			else {
				[self.delegate cellDidPressWithData:self.usualData withIndexPath:indexPath useCoreData:NO];
			}
		}
		else {
			if (indexPath.section == 0) {
				if (self.search) {
					[self.delegate cellDidPressWithData:self.searchCoreDataData withIndexPath:indexPath useCoreData:YES];
				}
				else {
					[self.delegate cellDidPressWithData:[[EKCoreDataProvider sharedInstance] fetchedEntitiesForEntityName:kEKEntityName] withIndexPath:indexPath useCoreData:YES];
				}
			}
			else {
				if (self.search) {
					[self.delegate cellDidPressWithData:self.searchPlistData withIndexPath:indexPath useCoreData:NO];
				}
				else {
					[self.delegate cellDidPressWithData:self.usualData withIndexPath:indexPath useCoreData:NO];
				}
			}
		}
	}
	else {
		NSAssert(self.delegate != nil, @"Delegate should not be nil");
	}
    
    [[tableView superview] endEditing:YES];
    
    [[[EKSettingsProvider alloc] init] setSectionWithRowData:@[[NSNumber numberWithInteger:indexPath.section], [NSNumber numberWithInteger:indexPath.row]]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL edit = NO;
    
	if ([tableView numberOfSections] == 1) {
		edit = NO;
	}
	else {
		if (indexPath.section == 1) {
			edit = NO;
		}
		else {
			edit = YES;
		}
	}
    
	return edit;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 2;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (aTableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[EKCoreDataProvider sharedInstance] deleteEntityWithEntityIndex:indexPath];
    self.delegate = self.appDelegate.splitViewController.viewControllers[0];
    if (self.delegate) {
        [self.delegate didDeleteRowWithIndexPath:indexPath];
    }
    else {
        NSAssert(self.delegate != nil, @"Delegate should not be nil");
    }
}

#pragma mark - Delegated stuff

- (void)scrollToSectionTop
{
    self.delegate = self.appDelegate.splitViewController.viewControllers[0];
	if (self.delegate) {
		[self.delegate sectionHeaderDidTap];
	}
	else {
		NSAssert(self.delegate != nil, @"Delegate should not be nil");
	}
}

@end
