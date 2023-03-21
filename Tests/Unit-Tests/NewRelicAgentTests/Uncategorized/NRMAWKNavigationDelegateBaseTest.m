//
//  NRMAWKNavigationDelegateBaseTest.m
//  NewRelicAgent
//
//  Created by Austin Washington on 7/26/17.
//  Copyright © 2023 New Relic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NRMAWKWebViewNavigationDelegate.h"
#import "NRTimer.h"
#import <WebKit/WebKit.h>
#import "NRMAWKFakeNavigationAction.h"

@interface NRWKNavigationDelegateBase ()
- (instancetype) initWithOriginalDelegate:(NSObject<WKNavigationDelegate>* __nullable __weak)delegate;
+ (NSURL*) navigationURL:(WKNavigation*) nav;
+ (NRTimer*) navigationTimer:(WKNavigation*) nav;
+ (void) navigation:(WKNavigation*)nav setURL:(NSURL*)url;
+ (void) navigation:(WKNavigation*)nav setTimer:(NRTimer*)timer;
@end

@interface NRMAWKNavigationDelegateBaseTest : XCTestCase <WKNavigationDelegate>
@property(strong) NRTimer* timer;
@property(strong) NSURL* url;
@property(strong) WKNavigation* web;
@property(strong) NRMAWKWebViewNavigationDelegate* navBase;
@property(strong) WKWebView* webView;


@end

@implementation NRMAWKNavigationDelegateBaseTest

- (void)setUp {
    [super setUp];
    self.navBase = [[NRMAWKWebViewNavigationDelegate alloc] initWithOriginalDelegate:self];
    self.web = [[WKNavigation alloc] init];
    self.url = [NSURL URLWithString: @"localhost"];
    self.timer = [[NRTimer alloc] init];
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = _navBase;
}

- (void)tearDown {
    [super tearDown];
}

- (void) testNilParameterPassing {
    @autoreleasepool {
        XCTAssertNoThrow([NRWKNavigationDelegateBase navigation:nil setURL:_url], @"");
        XCTAssertNil([NRWKNavigationDelegateBase navigationURL:_web]);
        
        XCTAssertNoThrow([NRWKNavigationDelegateBase navigation:nil setTimer:_timer], @"");
        XCTAssertNil([NRWKNavigationDelegateBase navigationTimer:_web]);
        //[NRWKNavigationDelegateBase navigationTimer:_web];
    }
}

- (void) testImpersonation {
    @autoreleasepool {
        XCTAssertTrue([self.navBase isKindOfClass:[self class]]);
        XCTAssertTrue([self.navBase isKindOfClass:[NRWKNavigationDelegateBase class]]);
    }
}

- (void) testDecidePolicyForNavigationAction {
    NSURLRequest* url = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"localhost"]];
    
    NRMAWKFakeNavigationAction *testAction = [[NRMAWKFakeNavigationAction alloc] initWith:url];
    
    [self.webView.navigationDelegate webView:self.webView decidePolicyForNavigationAction:testAction decisionHandler:^(WKNavigationActionPolicy policy){
        [testAction decisionHandler:policy];
    }];
    
    XCTAssertEqual(testAction.receivedPolicy, WKNavigationActionPolicyAllow);
    
    if (@available(iOS 13.0, *)) {
        [self.webView.navigationDelegate webView:self.webView decidePolicyForNavigationAction:testAction preferences:[[WKWebpagePreferences alloc] init] decisionHandler:^(WKNavigationActionPolicy policy, WKWebpagePreferences* preference){
            [testAction decisionHandler:policy];
        }];
        XCTAssertEqual(testAction.receivedPolicy, WKNavigationActionPolicyAllow);
    }
}

- (void) testDidReceiveAuthenticationChallenge {
    NSURLRequest* url = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"localhost"]];
    
    NRMAWKFakeURLAuthenticationChallenge *testChallenge = [[NRMAWKFakeURLAuthenticationChallenge alloc] initWith:url];
    
    [self.webView.navigationDelegate webView:self.webView didReceiveAuthenticationChallenge:[[NSURLAuthenticationChallenge alloc] init] completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential){
        [testChallenge completionHandler:disposition withCredential:credential];
    }];
    
    XCTAssertNil(testChallenge.credential);
    XCTAssertEqual(testChallenge.authenticationChallengeDisposition, NSURLSessionAuthChallengePerformDefaultHandling);
}

- (void) testDecidePolicyForNavigationResponse {
    NSURLRequest* url = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"localhost"]];
    
    NRMAWKFakeNavigationResponse *testResponse = [[NRMAWKFakeNavigationResponse alloc] initWith:url];
    
    [self.webView.navigationDelegate webView:self.webView decidePolicyForNavigationResponse:testResponse decisionHandler:^(WKNavigationResponsePolicy policy){
        [testResponse decisionHandler:policy];
    }];;
    
    XCTAssertEqual(testResponse.receivedPolicy, WKNavigationResponsePolicyAllow);
}

@end
