//
//  ViewController.h
//  BlueToothConnect
//
//  Created by 柴田　大介 on 2014/02/15.
//  Copyright (c) 2014年 dshibata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : UIViewController<MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
{
    MCPeerID *myPeerID;
    NSString *serviceType;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) MCPeerID *myPeerID;
@property (strong, nonatomic) NSString *serviceType;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (strong, nonatomic) MCSession *session;

@property (nonatomic) NSArray *sendArray;

- (IBAction)btnStartAdvertisingIPHONE:(id)sender;
- (IBAction)btnStopAdvertisingIPHONE:(id)sender;

@end