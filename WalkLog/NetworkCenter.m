//
//  NetworkCenter.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-18.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "NetworkCenter.h"

#import "GCDAsyncUdpSocket.h"

@interface NetworkCenter () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong, readwrite) NSNetServiceBrowser *browser;
@property (nonatomic, strong, readwrite) NSNetService *service;
@property (nonatomic, strong, readwrite) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong, readwrite) NSData *address;
@property (nonatomic, assign, readwrite) long tag;
@end

@implementation NetworkCenter

+ (instancetype)sharedCenter
{
    static NetworkCenter * __center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __center = [[NetworkCenter alloc] init];
    });
    return __center;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.browser = [[NSNetServiceBrowser alloc] init];
        self.browser.delegate = self;
    }
    return self;
}

- (void)startBrowser
{
    [self.browser searchForServicesOfType:@"_angle._udp." inDomain:@"local."];
}

#pragma mark - NSNetServiceBrowser

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserWillSearch");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserDidStopSearch");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"netServiceBrowserDidNotSearch:%@", errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowserDidFindDomain:%@:%@", domainString, moreComing?@"true":@"false");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowserDidFindService:%@:%@", aNetService.domain, moreComing?@"true":@"false");
    if (nil == self.service) {
        self.service = aNetService;
        self.service.delegate = self;
        [self.service resolveWithTimeout:5];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowserDidRemoveDomain:%@", domainString);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowserDidRemoveService:%@", aNetService.domain);
}

#pragma mark - NSNetService
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"netServiceDidResolveAddress:%@", sender.addresses);
    if (nil == self.address && sender.addresses.count > 0) {
        self.address = sender.addresses[0];
        if (nil == self.udpSocket) {
            self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                           delegateQueue:dispatch_get_main_queue()];
            self.tag = 1;
        }
    }
}

- (void)sendData:(NSData *)data
{
    if (self.udpSocket && data) {
        [self.udpSocket sendData:data
                       toAddress:self.address
                     withTimeout:1
                             tag:self.tag];
        self.tag ++;
    }
}

#pragma mark - GCDAsyncSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose:%@", error);
}

@end
