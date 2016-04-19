//
//  Sample2ViewController.m
//  ELComboBox
//
//  Created by Eddie Hiu-Fung Lau on 28/5/14.
//  Copyright (c) 2014 Eddie Hiu-Fung Lau. All rights reserved.
//

#import "Sample2ViewController.h"
#import <ELComboBox/ELComboBox.h>

#define kNumberOfRows 4
#define kIndexPathWithComboBox ([NSIndexPath indexPathForRow:kNumberOfRows-1 inSection:0])

@interface Sample2ViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ELComboBoxDataSource,
    ELComboBoxDelegate
>

@property (nonatomic,retain) NSArray *options;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic) CGRect boundsBeforeEditing;
@property (nonatomic,retain) ELComboBox *editingCmoboBox;
@property (nonatomic,retain) UIBarButtonItem *cancelEditButton;

@end

@implementation Sample2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sample 2";
        self.options = @[@"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine", @"ten"];
    }
    return self;
}

- (void) dealloc {
    self.tableView = nil;
    self.options = nil;
    [super dealloc];
}

- (void)loadView {

    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view = self.tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < kNumberOfRows - 1) {
        
        NSString *cellId = @"sampleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = [NSString stringWithFormat:@"Sample Cell %ld", (long)indexPath.row + 1L];
        }
        
        return cell;
        
    } else {
    
        NSString *cellId = @"comboBoxCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            CGRect frame = cell.contentView.bounds;
            frame.origin.x += 15.0;
            frame.origin.y = (cell.contentView.bounds.size.height - 30)/2.0;
            frame.size.width -= 15.0;
            frame.size.height = 25;
            ELComboBox *comboBox = [[ELComboBox alloc] initWithFrame:frame];
            comboBox.delegate = self;
            comboBox.dataSource = self;
            comboBox.textField.placeholder = @"Numbers";
            [cell.contentView addSubview:comboBox];
            
        }
        
        return cell;
    }
    
}

#pragma mark ELComboBoxDataSource

- (NSInteger)numberOfSectionsInComboBox:(ELComboBox *)comboBox {
    return 1;
}

- (NSInteger)comboBox:(ELComboBox *)comboBox numberOfOptionsInSection:(NSInteger)section {
    return self.options.count;
}

- (NSString *)comboBox:(ELComboBox *)comboBox textForOptionAtIndexPath:(NSIndexPath *)indexPath {
    return self.options[indexPath.row];
}

- (NSString *)comboBox:(ELComboBox *)comboBox keywordForOptionAtIndexPath:(NSIndexPath *)indexPath {
    return self.options[indexPath.row];
}

#pragma mark ELComboBoxDelegate

- (void)comboBoxDidBeginEditing:(ELComboBox *)comboBox {

    /* Scroll the row containing this combox to the top */
    CGRect rowRect = [self.tableView rectForRowAtIndexPath:kIndexPathWithComboBox];
    self.boundsBeforeEditing = self.tableView.bounds;
    CGRect bounds = self.tableView.bounds;
    
    CGFloat topInset = self.tableView.contentInset.top;
    bounds.origin.y = rowRect.origin.y - topInset;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.bounds = bounds;
    }];
    
    self.editingCmoboBox = comboBox;
    self.tableView.scrollEnabled = NO;
}

- (void) comboBox:(ELComboBox *)comboBox didSelectOptionAtIndexPath:(NSIndexPath *)indexPath {
    
    [comboBox endEditing:YES];
    
}

- (void)comboBoxDidEndEditing:(ELComboBox *)comboBox {
    
    self.editingCmoboBox = nil;
    self.tableView.scrollEnabled = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.bounds = self.boundsBeforeEditing;
    }];
    
    
}

- (UIView *) parentViewForOptionsViewInComboBox:(ELComboBox *)comboBox {
    return self.tableView;
}

@end
