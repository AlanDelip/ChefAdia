//
//  CAFoodPayViewController.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/9.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CAFoodPayViewController.h"
#import "Utilities.h"
#import "CAFoodPayTableViewCell.h"
#import "CAFoodDetailInCart.h"
#import "CAFoodCart.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define PAY_URL @"http://139.196.179.145/ChefAdia-1.0-SNAPSHOT/menu/addOrder"

@interface CAFoodPayViewController (){
    NSString *fontName;
}

@end

@implementation CAFoodPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fontName = [Utilities getFont];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_bowlInstructionLabel setFont:[UIFont fontWithName:fontName size:15]];
    [_ticketInstructionLabel setFont:[UIFont fontWithName:fontName size:15]];
    
    [_priceLabel setFont:[UIFont fontWithName:[Utilities getBoldFont] size:40]];
    [_timeLabel setFont:[UIFont fontWithName:fontName size:15]];
    [_countLabel setFont:[UIFont fontWithName:fontName size:15]];
    
    [_priceLabel setTextColor:[Utilities getColor]];
    
    //price label
    [_priceLabel setText:_price];
    
    //time label
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [fmt stringFromDate:now];
    [_timeLabel setText:dateString];
    
    //count label
    [_countLabel setText:[NSString stringWithFormat:@"(%d ITEM%s)", _totalNum, _totalNum <= 1 ? "" : "S"]];
    
    _cashButton.titleLabel.font = [UIFont fontWithName:fontName size:15];
    _visaButton.titleLabel.font = [UIFont fontWithName:fontName size:15];
    [_bowlSwitch setOnTintColor:[Utilities getColor]];
    [_ticketSwitch setOnTintColor:[Utilities getColor]];
    [_bowlSwitch setOn:NO];
    [_ticketSwitch setOn:NO];
}

- (IBAction)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)payAction:(id)sender{
    //CASH : TAG = 0
    //VISA : TAG = 1
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Sure to order?"
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Order"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         int ticket_info = [self.ticketSwitch isOn];
                                                         int bowl_info = [self.bowlSwitch isOn];
                                                         
                                                         UIButton *button = (UIButton *)sender;
                                                         
                                                         NSMutableArray *foodArr = [[NSMutableArray alloc] init];
                                                         for(CAFoodDetailInCart *food in self.payFoodArr){
                                                             NSDictionary *foodDict = @{
                                                                                        @"foodid" : food.foodID,
                                                                                        @"num" : [NSNumber numberWithInt:food.number],
                                                                                        };
                                                             [foodArr addObject:foodDict];
                                                         }
                                                         
                                                         NSDictionary *tempDict = @{
                                                                                    @"userid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],
                                                                                    @"time" : [self.timeLabel text],
                                                                                    @"food_list" : foodArr,
                                                                                    @"price" : [NSNumber numberWithDouble:[[[self.priceLabel text] substringFromIndex:1] doubleValue]],
                                                                                    @"ticket_info" : [NSNumber numberWithInt:ticket_info],
                                                                                    @"bowl_info" : [NSNumber numberWithInt:bowl_info],
                                                                                    @"pay_type" : [NSNumber numberWithInteger:button.tag],
                                                                                    };
                                                         
                                                         AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                                                         manager.requestSerializer = [AFJSONRequestSerializer serializer];
                                                         manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                                                              @"text/plain",
                                                                                                              @"text/html",
                                                                                                              nil];
                                                         [manager POST:PAY_URL
                                                            parameters:tempDict
                                                              progress:nil
                                                               success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                                                   NSDictionary *resultDict = (NSDictionary *)responseObject;
                                                                   if([[resultDict objectForKey:@"condition"] isEqualToString:@"success"]){
                                                                       
                                                                       [[CAFoodCart shareInstance] clearCart];
                                                                       
                                                                       UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Order success"
                                                                                                                                       message:nil
                                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                                                          style:UIAlertActionStyleDefault
                                                                                                                        handler:^(UIAlertAction *action){
                                                                                                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                                                        }];
                                                                       [alertC addAction:okAction];
                                                                       [self presentViewController:alertC animated:YES completion:nil];
                                                                       
                                                                   }else{
                                                                       NSLog(@"Error, MSG: %@", [resultDict objectForKey:@"message"]);
                                                                   }
                                                                   
                                                               }
                                                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                   NSLog(@"%@",error);
                                                               }];
                                                     }];
    [alertC addAction:cancelAction];
    [alertC addAction:okAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_payFoodArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CAFoodPayTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"CAFoodPayTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    CAFoodPayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    CAFoodDetailInCart *food = _payFoodArr[indexPath.row];
    cell.nameLabel.text = food.foodName;
    cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f",food.price];
    cell.numLabel.text = [NSString stringWithFormat:@"%d",food.number];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 10;
}

@end
