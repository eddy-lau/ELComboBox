//
//  MainViewController.m
//  ELComboBox
//
//  Created by Eddie Hiu-Fung Lau on 27/5/14.
//  Copyright (c) 2014 Eddie Hiu-Fung Lau. All rights reserved.
//

#import "Sample1ViewController.h"
#import <ELComboBox/ELComboBox.h>
#import "Sample2ViewController.h"

@interface Sample1ViewController ()

@end

@implementation Sample1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sample 1";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(didTapNextButton:)];
    }
    return self;
}

- (void) loadView {
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ELComboBox *comboBox = [[ELComboBox alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 25)];
    comboBox.options = @[@"one",@"two",@"three",@"four",@"five",@"six",@"seven",@"eight",@"nine",@"ten"];
    comboBox.textField.placeholder = @"Numbers";
    [view addSubview:comboBox];
    
    self.view = view;
    
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

- (void) didTapNextButton:(id)sender {
    
    [self.navigationController pushViewController:[[Sample2ViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
}

@end
