//
//  UIImage+JWWaterMark.h
//  joywok
//
//  Created by winds on 2018/6/25.
//  Copyright © 2018年 Dogesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JWWaterMark)
+ (void)waterMarkDefalutConfig;
+ (void)configWaterMarkTitle:(NSString *)title font:(UIFont *)font markColor:(UIColor *)markColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation;
//根据原始图片生成水印图片 重复的文字
+ (UIImage *)getWaterMarkImageWithImageSize:(CGSize)imageSize;
- (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor;
- (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation;

//直接生成水印图片 重复的文字
+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor;
+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize;
+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize imageFillColor:(UIColor *)fillColor;
+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize imageFillColor:(UIColor *)fillColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation;

//根据图片获取图片的主色调
- (UIColor*)mostColor;
//截图图片
- (UIImage *)createImageInRect:(CGRect)rect;
@end
