//
//  PTSBeaconManeger.m
//  PutTheSound
//
//  Created by Daisuke Shibata on 2014/02/15.
//  Copyright (c) 2014年 Toshiki Chiba. All rights reserved.
//

#import "PTSBeaconManeger.h"

@interface PTSBeaconManeger()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CBPeripheralManager *peripheralManager;

@property (nonatomic) NSTimer *stopAdvertisingTimer;

@end

@implementation PTSBeaconManeger

+(PTSBeaconManeger *)sharedManager
{
    static dispatch_once_t once_token;
    static PTSBeaconManeger *shared = nil;
    
    dispatch_once(&once_token, ^{
        shared = [[PTSBeaconManeger alloc] init];
    });
    return shared;
}

-(void)setupManagerWithDelegate:(id)delegate
{
    self._delegate = delegate;
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"D456894A-02F0-4CB0-8258-81C187DF45C2"];
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                               identifier:@"koganePJ"];
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

#pragma mark - CLLocationManagerDelegate methods
//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//}
//
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                break;
            case CLProximityNear:
                break;
            case CLProximityFar:
                break;
            default:
                break;
        }
        if (nearestBeacon.proximity != CLProximityUnknown) {
            [self sendLocalNotificationForMessage:@"近くに音楽聞いてる人がいるよ！"];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            break;
        case CBPeripheralManagerStatePoweredOn:
            break;
        case CBPeripheralManagerStateResetting:
            break;
        case CBPeripheralManagerStateUnauthorized:
            break;
        case CBPeripheralManagerStateUnknown:
            break;
        case CBPeripheralManagerStateUnsupported:
            break;
        default:
            break;
    }
}

- (void)startAdvertising:(long)trackID
{
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (self.stopAdvertisingTimer.isValid) {
        [self.stopAdvertisingTimer invalidate];
    }
    self.stopAdvertisingTimer = nil;
    self.stopAdvertisingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stopAdvertising) userInfo:nil repeats:NO];
    
    int major = (int)trackID / 1000;
    int minor = (int)trackID % 1000;
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major:major
                                                                           minor:minor
                                                                identifier:@"koganePJ"];
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

#pragma mark - Private methods
- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}

@end
