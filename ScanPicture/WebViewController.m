//
//  WebViewController.m
//  ScanPicture
//
//  Created by 韩小东 on 16/3/21.
//  Copyright © 2016年 HXD. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate>
@property (nonatomic,strong)    WKWebView   *webView;
@property (nonatomic,strong)    NSString    *url;
@end

@implementation WebViewController

-(WKWebView *)webView{
    if (!_webView) {
        CGFloat h1 = self.navigationController.navigationBar.frame.size.height;
        CGFloat h2 = [UIApplication sharedApplication].statusBarFrame.size.height;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-h1-h2)];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.webView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.url.length>0) {
        WKNavigation *nav = [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        NSLog(@"%@",nav);
    }
}

-(void)setUrlStr:(NSString *)urlStr{
    self.url = urlStr;
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"start");
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"error:%@",error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didcommitNavigation");
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
