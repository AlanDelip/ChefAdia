//
//  CAFindTableViewController.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/5.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CAFindTableViewController.h"
#import "CAFindItemTableViewCell.h"

@interface CAFindTableViewController ()

@end

@implementation CAFindTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CAFindItemTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"CAFindItemTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    CAFindItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImage *img;
    NSString *mainText;
    NSString *subText;
    switch (indexPath.row) {
        case 0:
            img = [UIImage imageNamed:@"FIND_1"];
            mainText = @"I WANT TO ADD MENU";
            subText = @"WE RECOMMEND ANY GREAT IDEA COMING FROM YOU!";
            break;
        case 1:
            img = [UIImage imageNamed:@"FIND_2"];
            mainText = @"I HAVE ADVICE";
            subText = @"WE ARE GLAD TO HEAR YOUR ADVICE AND ACCEPT IT AS SOON AS POSSIBLE.";
            break;
        default:
            break;
    }
    [cell.imgView setImage:img];
    [cell.mainLabel setText:mainText];
    [cell.subLabel setText:subText];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 10;
}

@end
