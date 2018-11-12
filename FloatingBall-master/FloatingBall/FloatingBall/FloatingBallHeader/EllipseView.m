//
//  EllipseView.m
//  testAnimation
//
//  Created by 罗祖根 on 2018/11/11.
//  Copyright © 2018年 罗祖根. All rights reserved.
//

#import "EllipseView.h"

@implementation EllipseView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//绘制椭圆
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *ellipsePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = ellipsePath.CGPath;
    shape.fillColor = [UIColor colorWithWhite:1 alpha:0.4f].CGColor;
    shape.strokeColor = [UIColor colorWithWhite:1 alpha:0.4f].CGColor;
    shape.lineWidth = 0.5f;
    [self.layer addSublayer:shape];
}


@end
