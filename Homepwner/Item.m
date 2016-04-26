//
//  Item.m
//  Homepwner
//
//  Created by SLboat on 2/17/16.
//  Copyright © 2016 SLboat. All rights reserved.
//

#import "Item.h"

@implementation Item

// Insert code here to add functionality to your managed object subclass
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

//插入新格子的唤醒
-(void)awakeFromInsert{
    [super awakeFromInsert];
    
    self.dateCreated = [NSDate date];
    
    // 创建一个NSUUID对象,然后取得它的字符串表示.
    NSUUID *uuid = [[NSUUID alloc]init];
    NSString *key = [uuid UUIDString];
    self.itemKey = key;
}

@end
