//
//  ItemStore.m
//  Homepwner
//
//  Created by Sen on 6/16/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"
#import "ImageStore.h"
@import CoreData;

@interface ItemStore ()

@property(nonatomic) NSMutableArray *privateItems;

@property(strong, nonatomic) NSMutableArray *allAssetTypes;
@property(strong, nonatomic) NSManagedObjectContext *context;
@property(strong, nonatomic) NSManagedObjectModel *model;

@end

@implementation ItemStore

+ (instancetype)sharedStore
{
    static ItemStore *sharedStore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });

    return sharedStore;
}

- (NSString *)itemArchivePath
{
    // 确保第一个参数是NSDocumentDirectory,而不是落叶
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    //取得第一个玩意
    NSString *documentDirectory = [documentDirectories firstObject];

    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

// If a programmer calls [[ItemStore alloc]init], let him
// Know the error of his ways
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"单例" reason:@"使用 +[ItemStore sharedStore]" userInfo:nil];
    return nil;
}

// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];

    if (self) {

        //在Homepwner.xcdatamodled里读取
        _model = [NSManagedObjectModel mergedModelFromBundles:nil]; //用实例变量,而不是存取器,哈.
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];
        
        //SQL文件去哪里
        NSString *path = self.itemArchivePath;
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) { //一步步,存在和建物
            @throw [NSException exceptionWithName:@"打开错误" reason:[error localizedDescription] userInfo:nil];
        }
        
        //创建管理上下文
        _context = [[NSManagedObjectContext alloc]init];
        _context.persistentStoreCoordinator = psc;

        [self loadAllItems]; //一次性载入保存
    }

    return self;
}

- (NSArray *)allItems
{
    return self.privateItems; //必要的话可以加上copy指示.
}

- (Item *)createItem
{
    //这里某时变成了随机,但这里什么都不需要...

    double order; //排序值
    
    if ([self.allItems count] == 0) {
        order = 1.0; //第一个
    }else{
        order = [[self.privateItems lastObject] orderingValue] + 1.0; //递增1
    }
    
    NSLog(@"在%lu个项目后添加, 序号是 %.2f", (unsigned long)[self.privateItems count], order); //哈,两位小数...
    
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.context]; //插入项目
    item.orderingValue = order;
    
    //哈,这里是老的了
    [self.privateItems addObject:item];
    
    return item;
}

- (void)removeItem:(Item *)item
{
    NSString *key = item.itemKey;

    //删除掉图片..
    [[ImageStore sharedStore] deleteImageForKey:key];

    [self.context deleteObject:item];
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return; //无需干活
    }
    // Get pointer to object being moved so you can re-insert it
    Item *item = self.privateItems[fromIndex];

    // Remove item from array
    [self.privateItems removeObjectAtIndex:fromIndex]; //移除..

    // Insert item in array at new location
    [self.privateItems insertObject:item atIndex:toIndex];
    
    // 计算一个序号给移动了的对象
    double lowerBound = 0.0;
    
    //它前面是否有个对象
    if (toIndex > 0) {
        lowerBound = [self.privateItems[toIndex - 1] orderingValue]; //前一个值为上限
    } else {
        //困扰:为何2.0?-因为可以是负数!为什么是2.0?1.0可能等值于下一个,但是两个之间最大值是1...
        lowerBound = [self.privateItems[1] orderingValue] - 2.0; //如果是第一个,就把前面的一个减去2.0
    }
    
    double upperBound = 0.0;
    
    //后面是不是还有个对象
    
    if (toIndex < [self.privateItems count] - 1) {
        upperBound = [self.privateItems[(toIndex + 1)] orderingValue]; //取得后一个的值,为上限
    } else {
        upperBound = [self.privateItems[toIndex - 1]orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"移动到顺序 %f", newOrderValue);
    item.orderingValue = newOrderValue;
    
}

- (BOOL)saveChanges
{
    NSError *error;
    BOOL sucessful = [self.context save:&error];
    if (!sucessful) {
        NSLog(@"错误在保存的时候: %@", [error localizedDescription]);
    }
    return sucessful;
}

- (void)loadAllItems{
    if (!self.privateItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.context]; //入口描述
        request.entity = e;
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES]; //排序描述
        request.sortDescriptors = @[sd]; //赋予排序,必须数组
        
        NSError *error; //准备收容错误的地方
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"获取失败" format:@"原因: %@", [error localizedDescription]];
        }
        self.privateItems = [[NSMutableArray alloc]initWithArray:result];
    }
}

- (NSArray *)allAssetTypes{
    if (!_allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc]init]; //建立请求
        NSEntityDescription *e = [NSEntityDescription entityForName:@"AssetType" inManagedObjectContext:self.context]; //条目描述
        request.entity = e; //绑定到请求上
        
        NSError *error = nil; //错误的盒子
        NSArray *result = [self.context executeFetchRequest:request error:&error]; //请求结果
        if (!result) {
            [NSException raise:@"取得错误" format:@"原因: %@", [error localizedDescription]];
        }
        _allAssetTypes = [result mutableCopy]; //镜像为可变的,哈!
        
        //初次的运行吗?
        if ([_allAssetTypes count] == 0) {
            NSManagedObject *type; //管理者自己
            
            type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context]; //建立自己
            [type setValue:@"家具" forKey:@"Label"];
            [_allAssetTypes addObject:type];
            
            //遗失岂不是人们的常例吗?
            type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context];
            //太多的沉重究竟指向什么呢?岂不是拯救之心嘛!
            [type setValue:@"珠宝" forKey:@"Label"]; //放置值
            [_allAssetTypes addObject:type];
            
            type = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:self.context];
            [type setValue:@"电器" forKey:@"Label"];
            [_allAssetTypes addObject:type];
        }
    }
    return _allAssetTypes; //这会总有啥子东西了吧
}

@end
