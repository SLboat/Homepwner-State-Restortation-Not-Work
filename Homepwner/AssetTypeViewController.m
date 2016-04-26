//
//  AssetTypeViewController.m
//  Homepwner
//
//  Created by SLboat on 3/2/16.
//  Copyright © 2016 SLboat. All rights reserved.
//

#import "AssetTypeViewController.h"
#import "ItemStore.h"
#import "Item.h"

NSString *const kCellID  = @"UITableViewCell";

@implementation AssetTypeViewController

- (instancetype)init{
    return [super initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style{ //忽略别的风格
    return [self init];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[ItemStore sharedStore]allAssetTypes]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath]; //查询格子

    NSArray *allAssets =[[ItemStore sharedStore]allAssetTypes];
    NSManagedObject *assetType = allAssets[indexPath.row];
    
    //键值编码取得标签
    NSString *assetLabel = [assetType valueForKey:@"Label"];
    cell.textLabel.text = assetLabel;
    
    //打勾当前选中的那个
    if (assetType == self.item.assetType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark; //打勾
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell; //制造完毕,遣送回去.

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSArray *allAssets = [[ItemStore sharedStore]allAssetTypes]; //所有的管家
    NSManagedObject *assetType = allAssets[indexPath.row]; //管家
    self.item.assetType = assetType; //大概取回来了啥子..取回来了管家!
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
