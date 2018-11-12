//
//  FloatingBallHeader.m
//  FloatingBall
//
//  Created by CygMac on 2018/6/7.
//  Copyright © 2018年 XunKu. All rights reserved.
//

#import "FloatingBallHeader.h"
#import "PaopaoButton.h"
#import <RBBAnimation/RBBTweenAnimation.h>
#import <pop/pop.h>
#import "EllipseView.h"

// 最多显示泡泡的数量
static NSInteger const PaopaoMaxNum = 10;

@interface FloatingBallHeader ()

// 背景图
@property (nonatomic, strong) UIImageView *bgIcon;
//// 泡泡button，固定十个，隐藏显示控制
@property (nonatomic, strong) NSMutableArray <PaopaoButton *> *paopaoBtnArray;
// 当前显示的泡泡数据
@property (nonatomic, strong) NSMutableArray *showDatas;
// x最多可选取的随机数值因数
@property (nonatomic, strong) NSMutableArray <NSNumber *> *xFactors;
// y最多可选取的随机数值因数
@property (nonatomic, strong) NSMutableArray <NSNumber *> *yFactors;
//水滴
@property (nonatomic, strong) UIImageView *shuidiImageView;
//水波纹
@property (nonatomic, strong) EllipseView *waterRippleView;

@end

@implementation FloatingBallHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 初始化数组
        self.showDatas = [NSMutableArray arrayWithCapacity:PaopaoMaxNum];
        
        // 布局
        [self addSubview:self.bgIcon];
        self.bgIcon.frame = frame;
        
        self.paopaoBtnArray = [[NSMutableArray alloc] init];
//        for (UIButton *paopao in self.paopaoBtnArray) {
//            paopao.frame = CGRectMake(0, 0, 60, 60);
//            [self addSubview:paopao];
//        }
    }
    return self;
}

- (void)setDataList:(NSArray *)dataList {
    _dataList = dataList;
    for (NSInteger i = 0; i < dataList.count; i++) {
        if (self.showDatas.count == PaopaoMaxNum) {
            return;
        }
        //PaopaoButton *paopao = self.paopaoBtnArray[i];
        PaopaoButton *paopao = [[PaopaoButton alloc] init];
        [paopao setPaopaoImage:[UIImage imageNamed:@"ic_float_paopao"]];
        paopao.frame = CGRectMake(0, 0, 60, 60);
        [paopao addTarget:self
                   action:@selector(paopaoClick:)
         forControlEvents:UIControlEventTouchUpInside];
        [paopao setBtnButtonTitle:self.dataList[i]];
        paopao.tag = i;
        paopao.hidden = NO;
        paopao.alpha = 1.0f;
        [paopao setTitle:dataList[i]];
        CGPoint randomPoint = [self getRandomPoint];
        paopao.center = randomPoint;
        [self addFloatAnimationWithPaopao:paopao];
        [self.showDatas addObject:dataList[i]];
        [self.paopaoBtnArray addObject:paopao];
        [self addSubview:paopao];
    }
}

#pragma mark - 泡泡加动画

- (void)addFloatAnimationWithPaopao:(PaopaoButton *)paopao {
    RBBTweenAnimation *sinus = [RBBTweenAnimation animationWithKeyPath:@"position.y"];
    sinus.fromValue = @(0);
    sinus.toValue = @(3);
    sinus.easing = ^CGFloat (CGFloat fraction) {
        return sin((fraction) * 2 * M_PI);
    };
    sinus.additive = YES;
    sinus.duration = [self getRandomNumber:3 to:5];
    sinus.repeatCount = HUGE_VALF;
    [paopao.layer addAnimation:sinus forKey:@"sinus"];
}

// 重置动画，因为页面disappear会将layer动画移除
- (void)resetAnimation {
//    for (NSInteger i = 0; i < self.showDatas.count; i++) {
//        PaopaoButton *paopao = self.paopaoBtnArray[i];
//        [self addFloatAnimationWithPaopao:paopao];
//    }
}

// 移除所有泡泡
- (void)removeAllPaopao {
//    for (PaopaoButton *paopao in self.paopaoBtnArray) {
//        paopao.hidden = YES;
//    }
    [self.showDatas removeAllObjects];
}

#pragma mark - 获取随机点坐标

- (CGPoint)getRandomPoint {
    CGFloat x = [self getRandomX];
    CGFloat y = [self getRandomY];
    return CGPointMake(x, y);
}

- (CGFloat)getRandomX {
    NSInteger index = arc4random() % self.xFactors.count;
    CGFloat factor = self.xFactors[index].floatValue;
    CGFloat x = 33 + (self.frame.size.width - 60) * factor;
    //[self.xFactors removeObjectAtIndex:index];
    return x;
}

- (CGFloat)getRandomY {
    NSInteger index = arc4random() % self.yFactors.count;
    CGFloat factor = self.yFactors[index].floatValue;
    CGFloat y = 130 + (FloatingBallHeaderHeight - 130 - 160) * factor;
    //[self.yFactors removeObjectAtIndex:index];
    return y;
}

/*
 - (CGPoint)getRandomPoint {
 CGFloat x = [self getRandomNumber:50 to:SCREEN_WIDTH - 50];
 CGFloat y = [self getRandomNumber:130 to:HomeHeaderBgIconHeight - 160];
 return CGPointMake(x, y);
 }
 */
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

//水波纹动画
- (void)showWaterRippleAnimation
{
    self.waterRippleView = [[EllipseView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.waterRippleView.center = self.shuidiImageView.center;
    [self addSubview:self.waterRippleView];
    //透明,动画从快到慢
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation easeOutAnimation];
    alphaAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    alphaAnimation.toValue= @(0);
    alphaAnimation.duration = 1.0f;
    [alphaAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [self.waterRippleView removeFromSuperview];
    }];
    //缩放,动画从快到慢
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation easeOutAnimation];
    //x y 缩放
    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
    //扩大为原来的2倍
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
    //持续时间1秒
    scaleAnimation.duration = 1.0f;
    
    [self.waterRippleView.layer pop_addAnimation:scaleAnimation forKey:nil];
    [self.waterRippleView pop_addAnimation:alphaAnimation forKey:nil];
}

//水滴动画
- (void)showShuidiAnimation
{
    //动画期间不能点击
    self.userInteractionEnabled = NO;
    
    self.shuidiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150/4, 250/4)];
    self.shuidiImageView.image = [UIImage imageNamed:@"shuidi"];
    self.shuidiImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height / 2);
    [self addSubview:self.shuidiImageView];
    
    //向下,动画从慢到快
    POPBasicAnimation *downAnimation = [POPBasicAnimation easeInAnimation];
    downAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionY];
    downAnimation.toValue = @(self.shuidiImageView.center.y + 150);
    downAnimation.duration = 0.7f;
    [downAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        self.userInteractionEnabled = YES;
        
        [self.shuidiImageView removeFromSuperview];
        //动画结束,开始水波纹动画
        [self showWaterRippleAnimation];
    }];
    
    //透明 动画从慢到快
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation easeInAnimation];
    alphaAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    alphaAnimation.fromValue = @(0.3);
    alphaAnimation.toValue= @(1);
    alphaAnimation.duration = 0.7f;
    
    //缩放 动画从慢到快
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation easeInAnimation];
    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(0.55, 0.55)];
    scaleAnimation.duration = 0.7f;
    
    [self.shuidiImageView.layer pop_addAnimation:scaleAnimation forKey:nil];
    [self.shuidiImageView pop_addAnimation:downAnimation forKey:nil];
    [self.shuidiImageView pop_addAnimation:alphaAnimation forKey:nil];
}

#pragma mark - 泡泡点击

- (void)paopaoClick:(PaopaoButton *)sender {
    /*
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        sender.frame = CGRectMake(sender.frame.origin.x, -70, sender.frame.size.width, sender.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            sender.hidden = YES;
            NSInteger num = 0;
            for (NSInteger i = 0; i < self.paopaoBtnArray.count; i++) {
                PaopaoButton *paopao = self.paopaoBtnArray[i];
                if (paopao.isHidden) {
                    num++;
                }
            }
            if (num == PaopaoMaxNum) {
                [self.showDatas removeAllObjects];
                self.xFactors = nil;
                self.yFactors = nil;
            }
            if ([self.delegate respondsToSelector:@selector(floatingBallHeader:didPappaoAtIndex:isLastOne:)]) {
                [self.delegate floatingBallHeader:self didPappaoAtIndex:sender.tag isLastOne:num == PaopaoMaxNum];
            }
        }
    }];
     */
    //水滴动画,在需要的时候调用,这里只是点击调用
    [self showShuidiAnimation];
    
    [sender setPaopaoImage:[UIImage imageNamed:@"yezi"]];
    [sender.layer removeAllAnimations];
    //旋转一直存在
    [self rotation:sender];
    //下边和左边的动画
    [self donwAndLeft:sender
             complete:^{
                 //做完了再右边到下边的动画,和透明度为0的动画一起
                 [self donwAndRight:sender
                           complete:^{
                               [sender removeFromSuperview];
                               [self.paopaoBtnArray removeObject:sender];
                               [self.showDatas removeObject:sender.titleLabel.text];
                               if ([self.delegate respondsToSelector:@selector(floatingBallHeader:didPappaoAtIndex:isLastOne:)]) {
                                   [self.delegate floatingBallHeader:self
                                                    didPappaoAtIndex:sender.tag
                                                           isLastOne:[self.paopaoBtnArray count] == 0];
                               }
                           }];
             }];
}

//旋转
- (void)rotation:(UIView *)yeziImageView
{
    POPBasicAnimation *rotationa = [POPBasicAnimation linearAnimation];
    rotationa.property = [POPAnimatableProperty propertyWithName: kPOPLayerRotation];
    rotationa.fromValue = @(0);
    rotationa.duration = 0.8f;
    //右旋
    rotationa.toValue = @(M_PI/2);
    [rotationa setCompletionBlock:^(POPAnimation *anim, BOOL finished) {

        POPBasicAnimation *rotationb = [POPBasicAnimation linearAnimation];
        rotationb.property = [POPAnimatableProperty propertyWithName: kPOPLayerRotation];
        rotationb.duration = 0.8f;
        rotationb.fromValue = @(M_PI/2);
        //回到最开始
        rotationb.toValue = @(0);
        [rotationb setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            //继续右旋
            [self rotation:yeziImageView];
        }];
        [yeziImageView.layer pop_removeAnimationForKey:@"rotationb"];
        [yeziImageView.layer pop_addAnimation:rotationb forKey:@"rotationb"];
    }];
    [yeziImageView.layer pop_removeAnimationForKey:@"rotationa"];
    [yeziImageView.layer pop_addAnimation:rotationa forKey:@"rotationa"];
}

- (void)donwAndLeft:(UIView *)yeziImageView
           complete:(void (^)(void))complete
{
    //先到左
    POPBasicAnimation *toleftxAnimation = [POPBasicAnimation linearAnimation];
    toleftxAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionX];
    toleftxAnimation.toValue = @(yeziImageView.center.x - 100);
    toleftxAnimation.duration = 1.0f;
    //向下
    POPBasicAnimation *downAnimation = [POPBasicAnimation linearAnimation];
    downAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionY];
    downAnimation.toValue = @(yeziImageView.center.y + 50);
    downAnimation.duration = 1.0f;
    [downAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if(finished)
        {
            if(complete)
            {
                complete();
            }
        }
    }];
    
    [yeziImageView pop_addAnimation:downAnimation forKey:@"downAnimation1"];
    [yeziImageView pop_addAnimation:toleftxAnimation forKey:@"toleftxAnimation"];
}

- (void)donwAndRight:(UIView *)yeziImageView
            complete:(void (^)(void))complete
{
    //到右
    POPBasicAnimation *torightxAnimation = [POPBasicAnimation linearAnimation];
    torightxAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionX];
    torightxAnimation.toValue = @(yeziImageView.center.x + 100);
    torightxAnimation.duration = 1.0f;
    //向下
    POPBasicAnimation *downAnimation = [POPBasicAnimation linearAnimation];
    downAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionY];
    downAnimation.toValue = @(yeziImageView.center.y + 50);
    downAnimation.duration = 1.0f;
    [downAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if(finished)
        {
            if(complete)
            {
                complete();
            }
        }
    }];
    
    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animation];
    alphaAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    alphaAnimation.toValue= @(0);
    alphaAnimation.duration = 1.0f;
    
    [yeziImageView pop_addAnimation:downAnimation forKey:@"downAnimation2"];
    [yeziImageView pop_addAnimation:torightxAnimation forKey:@"torightxAnimation"];
    [yeziImageView pop_addAnimation:alphaAnimation forKey:@"alphaAnimation"];
}

#pragma mark - Get

- (UIImageView *)bgIcon {
    if (!_bgIcon) {
        _bgIcon = [[UIImageView alloc] init];
        _bgIcon.contentMode = UIViewContentModeScaleAspectFill;
        _bgIcon.clipsToBounds = YES;
        _bgIcon.image = [UIImage imageNamed:@"BG_home_default"];
    }
    return _bgIcon;
}



//- (NSArray<PaopaoButton *> *)paopaoBtnArray {
//    if (!_paopaoBtnArray) {
//        NSMutableArray *marr = [NSMutableArray arrayWithCapacity:PaopaoMaxNum];
//        for (NSInteger i = 0; i < PaopaoMaxNum; i++) {
//            PaopaoButton *button = [[PaopaoButton alloc] init];
//            [button setPaopaoImage:[UIImage imageNamed:@"ic_float_paopao"]];
//
//            button.hidden = YES;
//            [button addTarget:self action:@selector(paopaoClick:) forControlEvents:UIControlEventTouchUpInside];
//            [marr addObject:button];
//        }
//        _paopaoBtnArray = marr;
//    }
//    return _paopaoBtnArray;
//}

- (NSMutableArray<NSNumber *> *)xFactors {
    if (!_xFactors) {
        _xFactors = [NSMutableArray arrayWithArray:@[@(0.00f), @(0.11f), @(0.22f), @(0.33f), @(0.44f), @(0.55f), @(0.66f), @(0.77f), @(0.88f), @(0.99)]];
    }
    return _xFactors;
}

- (NSMutableArray<NSNumber *> *)yFactors {
    if (!_yFactors) {
        _yFactors = [NSMutableArray arrayWithArray:@[@(0.00f), @(0.11f), @(0.22f), @(0.33f), @(0.44f), @(0.55f), @(0.66f), @(0.77f), @(0.88f), @(0.99)]];
    }
    return _yFactors;
}

@end
