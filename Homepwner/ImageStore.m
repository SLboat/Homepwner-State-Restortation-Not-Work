//
//  ImageStore.m
//  Homepwner
//
//  Created by Sen on 7/5/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()

@property(nonatomic, strong) NSMutableDictionary *dictionary;
- (NSString *)imagePathForKey:(NSString *)key;

@end

@implementation ImageStore

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:key];
}

+ (instancetype)sharedStore
{
    static ImageStore *sharedStore = nil; // 一个公共的属于自己的一个一个名字...
    //有趣:尽管这里的变量名和消息一样,但是这似乎并不太要紧,并不冲突.
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];// 制造
    }
    return sharedStore;
}

// No one should call init
- (instancetype)init
{

    @throw [NSException exceptionWithName:@"单例" reason:@"使用 +[ItemStore sharedStore]" userInfo:nil]; //抛出意外
    return nil;
}

// Sercret designated initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    //[self.dictionary setObject:image forKey:key];
    self.dictionary[key] = image;

    //创建图片的完整路径
    NSString *imagePath = [self imagePathForKey:key];

    //把图片转换成JPEG数据
    NSData *data = UIImageJPEGRepresentation(image, 0.5); //以0.5的压缩率来压缩这个UIImage的image图片

    //写入到完整路径里
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key
{
    //return [self.dictionary objectForKey:key]; //改写:字典常量

    // 如果可能,从字典里取得
    UIImage *result = self.dictionary[key];

    if (!result) {
        NSString *imagePath = [self imagePathForKey:key]; //取得路径

        //从文件创建对象
        result = [UIImage imageWithContentsOfFile:imagePath];

        //如果我们的确找到了图片,把它放在缓存里
        if (result) { //很多判断吗?看起来不会阿.
            self.dictionary[key] = result;
        } else {
            NSLog(@"错误: 没法儿找到%@", [self imagePathForKey:key]);
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];

    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"清理%lu个文件,弄出缓存...", (unsigned long)[self.dictionary count]);
    [self.dictionary removeAllObjects];
}

@end
