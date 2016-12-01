//
//  CANetworkManager.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/17.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CANetworkManager.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "JSONKit.h"

@implementation CANetworkManager

static CANetworkManager* _instance = nil;

#pragma mark - CONSTRUCTORS

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [CANetworkManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - NETWORK UTILITIES

- (void)checkNetwork{
    Reachability *reach = [Reachability reachabilityWithHostName:@"http://139.196.179.145/ChefAdia-0.0.1-SNAPSHOT/allDish.do"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
    
//    [self postMenu];
    [self getMenu];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Boolean isConnected;
    Reachability *reach = [notification object];
    
    if (![reach isReachable]) {
        NSLog(@"网络连接不可用");
        isConnected = NO;
    } else {
        if ([reach currentReachabilityStatus] == ReachableViaWiFi) {
            NSLog(@"正在使用WiFi");
            isConnected = YES;
        } else if ([reach currentReachabilityStatus] == ReachableViaWWAN) {
            NSLog(@"正在使用移动数据");
            isConnected = YES;
        }
    }
}

- (void)getFromHost:(NSString *)URL withParams:(NSDictionary *)params{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
//                                                         @"application/json",
                                                         nil];
    [manager GET:URL
      parameters:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSLog(@"JSON GET CLASS: %@", [responseObject class]);
             [self tranformTest:responseObject];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];

}

- (void)postToHost:(NSString *)URL withParams:(NSDictionary *)params{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"application/json",
                                                         @"text/html",
                                                         @"text/json",
                                                         nil];
    [manager POST:URL
       parameters:params
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
              NSLog(@"SUCCESS");
              NSLog(@"JSON POST: %@", responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"FAILED");
              NSLog(@"Error: %@", error);
          }];
}

- (void)tranformTest:(id)jsonObject{
    NSArray *array = (NSArray *)jsonObject;
    NSLog(@"%lu", [array count]);
    
    for(NSDictionary *dict in array){
        for(NSString *key in dict){
            NSLog(@"KEY : %@ VALUE : %@", key, dict[key]);
        }
    }
}

#pragma mark - METHODS

- (void)getMenu{
    [self getFromHost:@"http://139.196.179.145/ChefAdia-0.0.1-SNAPSHOT/allDish.do" withParams:nil];
}

- (void)postMenu{
    NSDictionary *parameters = @{
                                 @"name": @"RICE",
                                 @"type" : @"type1",
                                 @"price" : @"1.99",
                                 };
    [self postToHost:@"http://139.196.179.145/ChefAdia-0.0.1-SNAPSHOT/addDish.do"
            withParams:parameters];
}

- (void)getList{
    
}

- (void)getTickInfo{
    
}

- (void)buyTicket{
    
}

- (void)addOrder{
    
}

- (void)getOrderList{

}

- (void)getOrder{
    
}

- (void)comment{
    
}

@end
