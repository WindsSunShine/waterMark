//
//  UIImage+JWWaterMark.m
//  joywok
//
//  Created by winds on 2018/6/25.
//  Copyright © 2018年 Dogesoft. All rights reserved.
//

#import "UIImage+JWWaterMark.h"
#import "NSString+Extention.h"
#include <math.h>

//#define PorscheWaterMark
CGFloat radiansToDegrees(CGFloat degress) {return degress * M_PI / 180.0;};


UIColor *IMAGE_FILLCOLOR;
CGSize IMAGE_SIZE;
CGFloat CG_TRANSFORM_ROTATION =- (M_PI_2 / 10);
CGFloat VERTICAL_SPACE = 60;//竖直间距
CGFloat HORIZONTAL_SPACE =100 ;//水平间距
UIFont *MARK_FONT;
UIColor *MARK_COLOR;
NSString *TITLE;
@implementation UIImage (JWWaterMark)
+ (void)waterMarkDefalutConfig
{
    IMAGE_FILLCOLOR = [UIColor clearColor];
    IMAGE_SIZE = [UIScreen mainScreen].bounds.size;
    CG_TRANSFORM_ROTATION = - (M_PI_2 / 10);//旋转角度
    VERTICAL_SPACE = 60;
    HORIZONTAL_SPACE = 100;
    MARK_FONT = [UIFont systemFontOfSize:14];
    MARK_COLOR = [UIColor colorWithHex:0xe1e1e1];
    JWDataHelper *dataHelper = [JWDataHelper sharedDataHelper];
    TITLE = dataHelper.user.name;
    
}
+ (void)configWaterMarkTitle:(NSString *)title font:(UIFont *)font markColor:(UIColor *)markColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation;
{
    IMAGE_FILLCOLOR = [UIColor clearColor];
    IMAGE_SIZE = [UIScreen mainScreen].bounds.size;
    CG_TRANSFORM_ROTATION = transformRotation;//旋转角度
    VERTICAL_SPACE = verticalSpace;
    HORIZONTAL_SPACE = horizontalSpace;
    MARK_FONT = font;
    MARK_COLOR = markColor;
    TITLE = title;
}
+ (UIImage *)getWaterMarkImageWithImageSize:(CGSize)imageSize;
{
    //原始image的宽高
    CGFloat viewWidth = imageSize.width;
    CGFloat viewHeight = imageSize.height;

# ifdef PorscheWaterMark
    CGFloat strHeight = [TITLE sizeWithFont:[UIFont systemFontOfSize:24] maxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height;
    CGFloat distance = distanceWithLine(CGPointMake(0, viewHeight),CGPointMake(viewWidth, 0),CGPointMake(0, 0));
    CGFloat verticalSpace = 114;
    CGFloat horizontalSpace =80;
//    CGFloat transformRotation =  angleBetweenLines(CGPointMake(0, viewHeight),CGPointMake(0, 0), CGPointMake(0, viewHeight), CGPointMake(viewWidth, 0)) - M_PI_2;
    CGFloat transformRotation = -radiansToDegrees(18);
    [UIImage configWaterMarkTitle:TITLE font :[UIFont systemFontOfSize:24] markColor:[UIColor colorWithHex:0xe7e7e7] horizontalSpace:horizontalSpace verticalSpace:verticalSpace transformRotation:transformRotation];
#endif
    return [UIImage getWaterMarkImageWithTitle:TITLE markFont:MARK_FONT markColor:MARK_COLOR imageSize:imageSize imageFillColor:IMAGE_FILLCOLOR horizontalSpace:HORIZONTAL_SPACE verticalSpace:VERTICAL_SPACE transformRotation:CG_TRANSFORM_ROTATION];
}
//根据原始图片生成水印图片 重复的文字
- (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor {
    return [self getWaterMarkImageWithTitle:title markFont:markFont markColor:markColor horizontalSpace:HORIZONTAL_SPACE verticalSpace:VERTICAL_SPACE transformRotation:CG_TRANSFORM_ROTATION];
}

- (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation {
    
    UIImage *originalImage = self;
    
    UIFont *font = markFont;
    if (font == nil) {
        font = [UIFont systemFontOfSize:17];
    }
    UIColor *color = markColor;
    if (color == nil) {
        color = [self mostColor];
    }
    //原始image的宽高
    CGFloat viewWidth = originalImage.size.width;
    CGFloat viewHeight = originalImage.size.height;
    //为了防止图片失真，绘制区域宽高和原始图片宽高一样
//    UIGraphicsBeginImageContext(CGSizeMake(viewWidth, viewHeight));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(viewWidth, viewHeight), NO, 0);
    //先将原始image绘制上
    [originalImage drawInRect:CGRectMake(0, 0, viewWidth, viewHeight)];
    //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(viewWidth*viewWidth + viewHeight*viewHeight);
    //文字的属性
    NSDictionary *attr = @{
                           //设置字体大小
                           NSFontAttributeName: font,
                           //设置文字颜色
                           NSForegroundColorAttributeName :color,
                           };
    NSString* mark = title;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mark attributes:attr];
    //绘制文字的宽高
    CGFloat strWidth = attrStr.size.width;
    CGFloat strHeight = attrStr.size.height;
    
    //开始旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(viewWidth/2, viewHeight/2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(transformRotation));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewWidth/2, -viewHeight/2));
    
    //计算需要绘制的列数和行数
    int horCount = sqrtLength / (strWidth + horizontalSpace) + 1;
    int verCount = sqrtLength / (strHeight + verticalSpace) + 1;
    
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-viewWidth)/2;
    CGFloat orignY = -(sqrtLength-viewHeight)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat tempOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat tempOrignY = orignY;
    for (int i = 0; i < horCount * verCount; i++) {
        [mark drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:attr];
        if (i % horCount == 0 && i != 0) {
            tempOrignX = orignX;
            tempOrignY += (strHeight + verticalSpace);
        }else{
            tempOrignX += (strWidth + horizontalSpace);
        }
    }
    //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    return finalImg;
}

//直接生成水印图片 重复的文字
+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor {
    return [self getWaterMarkImageWithTitle:title markFont:markFont markColor:markColor imageSize:IMAGE_SIZE imageFillColor:IMAGE_FILLCOLOR horizontalSpace:HORIZONTAL_SPACE verticalSpace:VERTICAL_SPACE transformRotation:CG_TRANSFORM_ROTATION];
}

+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize {
    return [self getWaterMarkImageWithTitle:title markFont:markFont markColor:markColor imageSize:imageSize imageFillColor:IMAGE_FILLCOLOR horizontalSpace:HORIZONTAL_SPACE verticalSpace:VERTICAL_SPACE transformRotation:CG_TRANSFORM_ROTATION];
}

+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize imageFillColor:(UIColor *)fillColor {
    return [self getWaterMarkImageWithTitle:title markFont:markFont markColor:markColor imageSize:imageSize imageFillColor:fillColor horizontalSpace:HORIZONTAL_SPACE verticalSpace:VERTICAL_SPACE transformRotation:CG_TRANSFORM_ROTATION];
}

+ (UIImage *)getWaterMarkImageWithTitle:(NSString *)title markFont:(UIFont *)markFont markColor:(UIColor *)markColor imageSize:(CGSize)imageSize imageFillColor:(UIColor *)fillColor horizontalSpace:(CGFloat)horizontalSpace verticalSpace:(CGFloat)verticalSpace transformRotation:(CGFloat)transformRotation {
    
    UIFont *font = markFont;
    UIColor *color = markColor;
    
    //原始image的宽高
    CGFloat viewWidth = imageSize.width;
    CGFloat viewHeight = imageSize.height;
    //为了防止图片失真，绘制区域宽高和原始图片宽高一样
//    UIGraphicsBeginImageContext(CGSizeMake(viewWidth, viewHeight));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(viewWidth, viewHeight), NO, 0);
    //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(viewWidth*viewWidth + viewHeight*viewHeight);
    //文字的属性
    NSDictionary *attr = @{
                           //设置字体大小
                           NSFontAttributeName: font,
                           //设置文字颜色
                           NSForegroundColorAttributeName :color,
                           };
    NSString* mark = title;
    if (!mark) {
        JWDataHelper *dataHelper = [JWDataHelper sharedDataHelper];
        mark = dataHelper.user.name;
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mark attributes:attr];
    //绘制文字的宽高
    CGFloat strWidth = attrStr.size.width;
    CGFloat strHeight = attrStr.size.height;
    //开始旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, viewWidth, viewHeight));
    
    //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(viewWidth/2, viewHeight/2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(transformRotation));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewWidth/2, -viewHeight/2));
    
    //计算需要绘制的列数和行数
    int horCount = sqrtLength / (strWidth + horizontalSpace) + 1;
    int verCount = sqrtLength / (strHeight + verticalSpace) + 1;
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-viewWidth)/2;
    CGFloat orignY = -(sqrtLength-viewHeight)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat tempOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat tempOrignY = orignY;
    for (int i = 0; i < horCount * verCount; i++) {
        [mark drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:attr];
        if (i % horCount == 0 && i != 0) {
            tempOrignX = orignX;
            tempOrignY += (strHeight + verticalSpace);
        }else{
            tempOrignX += (strWidth + horizontalSpace);
        }
    }
    //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    return finalImg;
}
//根据图片获取图片的主色调
- (UIColor*)mostColor {
    UIImage *image = self;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(image.size.width/2, image.size.height/2);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    if (data == NULL) return nil;
    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    
    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {
            int offset = 4*(x*y);
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];
            if (alpha>0) {//去除透明
                if (red==255&&green==255&&blue==255) {//去除白色
                }else{
                    NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
                    [cls addObject:clr];
                }
                
            }
        }
    }
    CGContextRelease(context);
    //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;
    while ( (curColor = [enumerator nextObject]) != nil )
    {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if ( tmpCount < MaxCount ) continue;
        MaxCount=tmpCount;
        MaxColor=curColor;
        
    }
    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}

//截图图片
- (UIImage *)createImageInRect:(CGRect)rect {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(newImageRef);
    return newImage;
}


CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
    
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    return rads;
    return radiansToDegrees(rads);
    
}

//垂足交点
CGFloat distanceWithLine(CGPoint p1, CGPoint p2, CGPoint x0) {
    float A=p2.y-p1.y;
    float B=p1.x-p2.x;
    float C=p2.x*p1.y-p1.x*p2.y;
    
    float x=(B*B*x0.x-A*B*x0.y-A*C)/(A*A+B*B);
    float y=(-A*B*x0.x+A*A*x0.y-B*C)/(A*A+B*B);
    //点到直线距离
    float d=(A*x0.x+B*x0.y+C)/sqrt(A*A+B*B);
    NSLog(@"d======%f",d);
    return d;

}
//-(CGFloat)pedalPoint: (CGPoint)p1 : (CGPoint )p2: (CGPoint)x0{
//
//}
@end
