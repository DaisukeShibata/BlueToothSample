//
//  PTSBlueToothManagerr.h
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PTSBlueToothManegerDelegate <NSObject>

-(void)setPersonalData:(NSData *)data;

@end

@interface PTSBlueToothManager:NSObject<MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@property (strong, nonatomic) MCPeerID *myPeerID;
@property (strong, nonatomic) NSString *serviceType;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (strong, nonatomic) MCSession *session;

@property (nonatomic) NSArray *sendArray;
@property (nonatomic, assign)id<PTSBlueToothManegerDelegate> _delegate;

-(void)setupManagerWithDelegate:(id)delegate;

+ (PTSBlueToothManager *)sharedManager;
- (void)startAdvertising:(NSDictionary *)dic;


@end
