//
//  BNRItem.m
//  RandomItems
//
//  Created by Sen on 5/14/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "Item.h"


@implementation Item

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.itemName forKey:@"itemName"];
    [aCoder encodeObject:self.serialNumber forKey:@"serialNumber"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.itemKey forKey:@"itemKey"];
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];

    [aCoder encodeInt:self.valueInDollars forKey:@"valueInDollars"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _itemName = [aDecoder decodeObjectForKey:@"itemName"];
        _serialNumber = [aDecoder decodeObjectForKey:@"serialNumber"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _itemKey = [aDecoder decodeObjectForKey:@"itemKey"];
        _thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];

        _valueInDollars = [aDecoder decodeIntForKey:@"valueInDollars"];
    }
    return self;
}

+ (instancetype)randomItem
{
    //创建一个三个形容词的不可变数组
    NSArray *randomAdjectiveList = @[@"Fluffy", @"Rusty", @"Shiny"];

    //创建一个三个毛刺的不可变数组
    NSArray *randomNounList = @[@"Bear", @"Spork", @"Mac"];

    // Get the index of a random adjective/noun from the lists
    // Note: The % operator, called the modulo operator, gives
    // you the remainder.So adjectiveIndex is a random number
    // from 0 to 2 inclusive.
    NSInteger adjectiveIndex = arc4random() % [randomAdjectiveList count];
    NSInteger nounIndex = arc4random() % [randomNounList count];

    // Note the NSInteger is not an object, but a type definition for "long"

    NSString *randomName = [NSString stringWithFormat:@"%@ %@", randomAdjectiveList[adjectiveIndex], randomNounList[nounIndex]];
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + arc4random() % 10, //数字的随机...字符的魔法
                                    'A' + arc4random() % 26, //大写字母的随机...char的艺术
                                    '0' + arc4random() % 10,
                                    'A' + arc4random() % 26,
                                    '0' + arc4random() % 10];
    int randomValue = arc4random() % 100;

    Item *newItem = [[self alloc] initWithItemName:randomName valueInDollars:randomValue serialNumber:randomSerialNumber];
    return newItem; //建立起来了...瞧,一个类方法初始化了一个实例,返回了这个实例,这就是它的所有活儿了.
}

- (NSString *)description
{
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, recorded on %@", self.itemName, self.serialNumber, self.valueInDollars, self.dateCreated];
    return descriptionString;
}

- (instancetype)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *)sNumber
{
    // 呼叫父类的指定初始化器
    self = [super init];

    // 呼叫这个父类的指定初始化器成功了?
    if (self) {
        // 给这个实例变量一个初始值
        _itemName = name;
        _serialNumber = sNumber;
        _valueInDollars = value;
        // 设置 _dateCreated 为当前的时间和日期
        _dateCreated = [[NSDate alloc] init]; //或者只是date类方法?

        // Create an NSUUID object - and get its string representation
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        _itemKey = key;
    }

    // 返回新初始化后的地址
    return self;
}

- (instancetype)initWithItemName:(NSString *)name serialNumber:(NSString *)sNumber
{
    return [self initWithItemName:name valueInDollars:0 serialNumber:sNumber];
}

- (instancetype)initWithItemName:(NSString *)name
{
    return [self initWithItemName:name valueInDollars:0 serialNumber:@""]; //空掉但保留一部分.
}

- (instancetype)init
{
    return [self initWithItemName:@"Item"];
}

- (void)dealloc
{
    NSLog(@"正在销毁: %@", self); //摧毁自身
}

- (void)setItemName:(NSString *)itemName
{
    _itemName = [itemName copy];
}

- (void)setThumbnailFromImage:(UIImage *)image
{
    CGSize origImageSize = image.size;

    //缩略图的大小
    CGRect newRect = CGRectMake(0, 0, 40, 40);

    //搞出来缩放比例,接下来使得可以维持它.
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);

    //创建一个带有这样缩放比例的透明位图
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0); //0.0是尊重设备尺寸

    //创建一个椭圆的路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];

    //让随后的东西,都画在上面....我们在一个画板上.
    [path addClip];

    //把图片放在缩略图中间
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width; //缩小...
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;

    //在上面创建图片
    [image drawInRect:projectRect];

    //从上下文取得图片,保有它作为我们的缩略图
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;

    //清理图片上下文资源,我们完事了.
    UIGraphicsEndImageContext();

}

@end
