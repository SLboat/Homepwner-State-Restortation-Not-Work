//
//  ImageTransformer.m
//  Homepwner
//
//  Created by SLboat on 2/27/16.
//  Copyright © 2016 SLboat. All rights reserved.
//

#import "ImageTransformer.h"
@import UIKit;

@implementation ImageTransformer

+ (Class)transformedValueClass{
    return [NSData class];
}

- (id)transformedValue:(id)value{
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
         
    return UIImagePNGRepresentation(value); //图片数据
}

- (id)reverseTransformedValue:(id)value{
    return [UIImage imageWithData:value];
}


@end
