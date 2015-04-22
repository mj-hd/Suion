//
//  AboutViewController.m
//  Suion
//
//  Created by mjhd on 2014/08/08.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *WebView;
@property (weak, nonatomic) IBOutlet UINavigationBar *ToolBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *ToolBarItem;

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"閉じる" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    [_ToolBarItem setLeftBarButtonItem:back];
    
    NSString*     path    = [[NSBundle mainBundle] pathForResource:@"Suion" ofType:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    
    [_WebView loadRequest:request];
}
     
- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
