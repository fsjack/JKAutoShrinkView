//
//  JKViewController.m
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-13.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "JKViewController.h"

@interface JKViewController ()<UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) UISearchBar *searchBar;
@end

@implementation JKViewController
- (NSString *)title{
    return NSLocalizedString(@"Demo", @"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UISearchBar *searchBar = [[UISearchBar alloc] init];
//    self.navigationItem.titleView = searchBar;
    self.searchBar = searchBar;
    searchBar.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    
    [self requestWebsiteWithURL:@"http://www.google.com"];
}

- (void)requestWebsiteWithURL:(NSString *)urlString{
    self.searchBar.text = urlString;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark -
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self requestWebsiteWithURL:searchBar.text];
}

@end
