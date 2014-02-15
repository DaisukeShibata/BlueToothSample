//
//  PTSBlueToothManager.m
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSBlueToothManager.h"


@interface PTSBlueToothManager()
@end

@implementation PTSBlueToothManager
@synthesize myPeerID;
@synthesize serviceType;
@synthesize nearbyServiceAdvertiser;
@synthesize nearbyServiceBrowser;
@synthesize session;
@synthesize _delegate;


#pragma mark - Public method
+(PTSBlueToothManager *)sharedManager
{
    static dispatch_once_t once_token;
    static PTSBlueToothManager *shared = nil;
    
    dispatch_once(&once_token, ^{
        shared = [[PTSBlueToothManager alloc] init];
    });
    return shared;
}

-(void)setupManagerWithDelegate:(id)delegate
{
    self._delegate = delegate;
    
    NSUUID *uuid = [NSUUID UUID];
    myPeerID = [[MCPeerID alloc] initWithDisplayName:[uuid UUIDString]];
    serviceType = @"koganePJ";
    
    nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:serviceType];
    nearbyServiceBrowser.delegate = self;
    session = [[MCSession alloc] initWithPeer:myPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    
    //ブラウジング,アドバタイズ開始
    [nearbyServiceBrowser startBrowsingForPeers];
//    [self startAdvertising];
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

# pragma mark - MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    if(error){
        NSLog(@"[error localizedDescription] %@", [error localizedDescription]);
    }
}

//ピアが発見されたときに呼ばれる
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [self showAlert:@"ピア発見！" message:peerID.displayName];
    
    [nearbyServiceBrowser invitePeer:peerID toSession:session withContext:[@"Welcome" dataUsingEncoding:NSUTF8StringEncoding] timeout:10];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
}


# pragma mark - MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    if(error){
        NSLog(@"%@", [error localizedDescription]);
        [self showAlert:@"ERROR didNotStartAdvertisingPeer" message:[error localizedDescription]];
    }
}

//ピアに招待されたときに呼ばれる
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    //承認する
    invitationHandler(TRUE, self.session);
    [self showAlert:@"承認！！" message:@"accept invitation!"];
}

#pragma mark - MCSessionDelegate
//データを受信したときに呼ばれるメソッド
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
//    NSDictionary *reverse = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self._delegate respondsToSelector:@selector(setPersonalData:)]) {
            [self._delegate setPersonalData:data];
        }
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

//招待を受け入れ直後に呼ばれるメソッド
//ここでデータの送信を行う
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state == MCSessionStateConnected && self.session){
        NSError *error;
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"げっと" forKey:@"GET"];
        NSData *targetData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [self.session sendData:targetData toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error:&error];
    }
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(TRUE);
}

- (void)startAdvertising
{
    NSDictionary *discoveryInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"foo", @"bar", @"bar", @"foo", nil];
    nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID discoveryInfo:discoveryInfo serviceType:serviceType];
    nearbyServiceAdvertiser.delegate = self;
    [nearbyServiceAdvertiser startAdvertisingPeer];
}
-(void)startAdvertise:(NSDictionary *)dic
{
    [nearbyServiceAdvertiser stopAdvertisingPeer];
    [self startAdvertising];
}
-(void)stopAdvertise:(NSDictionary *)dic
{
    [nearbyServiceAdvertiser stopAdvertisingPeer];
}
@end
