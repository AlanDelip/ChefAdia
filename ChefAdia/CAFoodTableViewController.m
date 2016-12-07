//
//  CAFoodTableViewController.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/8.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CAFoodTableViewController.h"
#import "CAFoodTableViewCell.h"
#import "CAFoodManager.h"
#import "CAFoodMenu.h"
#import "Utilities.h"
#import "CAFoodDetailTableViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define MENU_URL @"http://139.196.179.145/ChefAdia-1.0-SNAPSHOT/menu/getMenu"

@interface CAFoodTableViewController (){
    NSString *fontName;
}

@end

@implementation CAFoodTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    fontName = [Utilities getFont];
    
    //加载食物大类
    _menuArr = [[NSMutableArray alloc] init];
    [self loadMenu];
    
    _backgroundView.image = [UIImage imageNamed:@"FOOD_TITLE"];
    _menuLabel.font = [UIFont fontWithName:fontName size:15];
    _name1Label.font = [UIFont fontWithName:[Utilities getBoldFont] size:40];
    _name2Label.font = [UIFont fontWithName:fontName size:20];
    _contactLabel.font = [UIFont fontWithName:fontName size:15];
    
    [_easyOrderButton.titleLabel setFont: [UIFont fontWithName:[Utilities getBoldFont] size:15]];
    
    _name1Label.text = @"KRAYC'S";
    _name2Label.text = @"CHINESE FOOD";
    _contactLabel.text = @"XIANLIN AVENUE\n10:00 A.M. ~ 22:00 P.M.";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMenu{

    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         nil];
    [manager GET:MENU_URL
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSDictionary *resultDict = (NSDictionary *)responseObject;
             if([[resultDict objectForKey:@"condition"] isEqualToString:@"success"]){
                 NSArray *resultArr = (NSArray *)[resultDict objectForKey:@"data"];
                 for(NSDictionary *dict in resultArr){
                     CAFoodMenu *tmpMenu = [[CAFoodMenu alloc] initWithID:[[dict valueForKey:@"menuid"] intValue]
                                                                   andPic:[dict valueForKey:@"pic"]
                                                                  andName:[dict valueForKey:@"name"]
                                                                   andNum:[[dict valueForKey:@"num"] intValue]];
                     [weakSelf.menuArr addObject:[tmpMenu copy]];
                 }
                 [weakSelf.tableView reloadData];
             }else{
                 NSLog(@"Error, MSG: %@", [resultDict objectForKey:@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [_menuArr count];
        default:
            return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        //注册 nib 的方法，来使用.xib 的cell
        static NSString *CellIdentifier = @"CAFoodTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"CAFoodTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        CAFoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //配置 cell 细节
        CAFoodMenu *item = _menuArr[indexPath.row];
        cell.nameLabel.text = [item name];
        cell.numberLabel.text = [NSString stringWithFormat:@"%d SELECTION%s", [item number], [item number] <= 1 ? "" : "S"];
        
        NSURL *imageUrl = [NSURL URLWithString:[item pic]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        [cell.bgView setImage:image];
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        [self performSegueWithIdentifier:@"detailSegue" sender:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 250;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailSegue"]){
        CAFoodDetailTableViewController *caFoodDetailTableViewController = (CAFoodDetailTableViewController *)[segue destinationViewController];
        NSIndexPath *path = (NSIndexPath *)sender;
        CAFoodMenu *caFoodMenu = (CAFoodMenu *)_menuArr[path.row];
        [caFoodDetailTableViewController setFoodType:caFoodMenu];
    }
}

@end
