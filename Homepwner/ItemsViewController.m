//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Sen on 6/15/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "ItemsViewController.h"
#import "Item.h"
#import "ItemStore.h"
#import "DetailViewController.h"
#import "ItemCell.h"
#import "ImageStore.h"
#import "ImageViewController.h"

@interface ItemsViewController () <UIPopoverControllerDelegate, UIDataSourceModelAssociation>

@property(nonatomic, strong) IBOutlet UIView *headerView; //来自练习的?

@property(strong, nonatomic) UIPopoverController *imagePopover;

@end

@implementation ItemsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateTabelViewForDynamicTypeSize];
}

- (void)updateTabelViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;

    if (!cellHeightDictionary) {
        cellHeightDictionary = @{
            UIContentSizeCategoryExtraSmall: @44,
            UIContentSizeCategorySmall:@44,
            UIContentSizeCategoryMedium:@44,
            UIContentSizeCategoryLarge:@44,
            UIContentSizeCategoryExtraLarge:@55,
            UIContentSizeCategoryExtraExtraLarge: @65,
            UIContentSizeCategoryExtraExtraExtraLarge: @75
        };
    }
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];     //获得字体类别
    NSNumber *cellHeight = cellHeightDictionary[userSize]; //TODO:避免触发为空
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];     //重载
}

- (IBAction)addNewItem:(id)sender
{
    // Create a new BNRItem and add it to the store
    Item *newItem = [[ItemStore sharedStore] createItem];

    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:YES];
    detailViewController.item = newItem;
    detailViewController.dismissBlock = ^{
        [[ItemStore sharedStore]saveChanges]; //保存去,管它呢
        [self.tableView reloadData];
    };

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    /* 奇怪的代码 - 演示视图插入 */
    //    navController.modalPresentationStyle = UIModalPresentationCurrentContext; //覆盖当前视图

    //    self.definesPresentationContext = YES; //不要再往祖先去寻找...搜索到自身就返回

    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    navController.restorationIdentifier = NSStringFromClass(navController.class);
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (instancetype)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";

        // Create a new bar button item that will send
        // addNewItem: to BNRItemViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];

        // Set this bar button item as the right item in the navigationItem
        navItem.rightBarButtonItem = bbi;

        navItem.leftBarButtonItem = self.editButtonItem;

        //通知所在
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(updateTabelViewForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];

        //状态恢复
        self.restorationIdentifier = NSStringFromClass(self.class);
        //TODO: 继续剩下的...
        
        self.restorationClass = self.class; //指定的恢复类所在.
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self]; //除去自己
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma message "Ignoring designated initializer warnings"
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];

    // 注册这个nib,它包含了格子
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ItemCell"];

    UIView *header = self.headerView;
    [self.tableView setTableHeaderView:header]; //放置头顶视图.

    self.tableView.rowHeight = 45.f;
    
    self.tableView.restorationIdentifier = @"ItemsViewControllerTableView"; //这里是视视图的恢复标识
}

#pragma mark - 表格数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    // UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"]; //风格,标识,1

    //创建或者重用格子
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];

    // Set the text on the cell with the description of the item
    // that is at the nth index of items,where n = row this cell
    // will appear in on the tablevie
    NSArray *items = [[ItemStore sharedStore] allItems]; //取得所有的内容
    Item *item = items[indexPath.row]; //取出一个内容

    //用内容来配置格子
    cell.nameLebel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;
    cell.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)item.valueInDollars];

    cell.thumbnailView.image = item.thumbnail;

    __weak ItemCell *weakCell = cell; //弱化,Block本身不保留自己

    cell.actionBlock = ^{
        NSLog(@"将要显示图片给: %@", item);

        ItemCell *strongCell = weakCell; //强化,执行的时候,不给释放...执行完后,自己不存在了...

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) { //iPad家族

            NSString *itemKey = item.itemKey;

            //如果这里没有图片, 我们啥也不需要显示
            UIImage *img = [[ImageStore sharedStore] imageForKey:itemKey];

            if (!img) {
                return;
            }

            //制造一个矩形给缩略图的框架-相对于我们的表格视图.
            //这里将可能会引发一个报警?
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds fromView:strongCell.thumbnailView];

            //创建一个图片视图控制器然后设置它的图片
            ImageViewController *ivc = [[ImageViewController alloc] init];
            ivc.image = img;

            //从矩形里展开一个600x600的浮出框.
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

        }
    };

    return cell; //格子建造完毕了!
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[ItemStore sharedStore] allItems];
        Item *item = items[indexPath.row];
        [[ItemStore sharedStore] removeItem:item];

        //Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[ItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

#pragma mark - 表格委托

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:NO];

    NSArray *items = [[ItemStore sharedStore] allItems];
    Item *selectedItem = items[indexPath.row];

    // Give detail view controller a pointer to the item object jin row
    detailViewController.item = selectedItem;

    // Push it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - 浮出框委托
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil; //释放
}

#pragma mark -
#pragma mark 恢复玩意
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[self alloc] init];
}

#pragma mark -
#pragma mark 恢复一些表格的玩意
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"]; //编码编辑模式
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"]; //解开编辑,反向的
    
    [super decodeRestorableStateWithCoder:coder];
}

-(NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view{
    NSString *identifier = nil;
    
    if (idx && view) {
        //Return an identifier of the given NSIndexPath, in case next time the data source changes
        Item *item = [[ItemStore sharedStore]allItems][idx.row];
        identifier = item.itemKey;
        NSLog(@"保存数据: %@", identifier);
    }
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view{
    NSIndexPath *indexPath = nil;
    
    if (identifier && view) {
        NSArray *items = [[ItemStore sharedStore]allItems];
        for (Item *item in items) {
            if ([identifier isEqualToString:item.itemKey]) {
                int row = (int)[items indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                NSLog(@"恢复了数据: %@", identifier);
                break;
            }
        }
    }
    
    return indexPath;
}

@end
