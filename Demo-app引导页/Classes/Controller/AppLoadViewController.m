//
//  AppLoadViewController.m
//  Demo-app引导页
//
//  Created by Suning on 16/8/5.
//  Copyright © 2016年 jf. All rights reserved.
//

#import "AppLoadViewController.h"
#import "UIView+Frame.h"
#import "ViewController.h"

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

#define SkipTime    10

@interface AppLoadViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    NSInteger _countTime;
}

@property(nonatomic,strong) NSArray *imgArr;

@property(nonatomic,strong) UIButton *enterBtn;
/** 倒计时按钮 */
@property(nonatomic,strong) UIButton *skipBtn;
@property(nonatomic,strong) NSTimer *timer;

@end

@implementation AppLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgArr = [NSArray arrayWithObjects:@"HELPER_1",@"HELPER_2",@"HELPER_3", nil];
    [self setUpBackground];
    [self.view addSubview:self.skipBtn];
    
    [self startTimer];
//    [self shutDownByGCD];
}

-(void)setUpBackground{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    //取消重复滚动
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake(kScreenWidth * self.imgArr.count, 0);
    [self.view addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth/2, 30)];
    _pageControl.centerX = kScreenWidth/2;
    _pageControl.numberOfPages = self.imgArr.count;
    _pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self.view addSubview:_pageControl];
    
    for (NSInteger i=0; i<self.imgArr.count; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight)];
        imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"HELPER_%ld",i+1]];
        [_scrollView addSubview:imgView];
        
        if (i==2) {
            [imgView addSubview:self.enterBtn];
            imgView.userInteractionEnabled = YES;
        } else {
            [self.enterBtn removeFromSuperview];
        }
    }
}

#pragma mark - GCD倒计时
-(void)shutDownByGCD{
    //倒计时时间+1
    __block NSInteger timeOut = SkipTime + 1;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if (timeOut <= 0) { //倒计时结束
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //这样写不会造成循环引用，只有block是直接或间接作为self的属性时这样写才有问题，此时就需要用weakself了
                [self goToMainPage];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.skipBtn setTitle:[NSString stringWithFormat:@"跳过%ld%@",(long)timeOut,@"s"] forState:UIControlStateNormal];
            });
            timeOut--;
        }
    });
    dispatch_resume(timer);
    
}

#pragma mark - 定时器倒计时
-(void)startTimer{
    _countTime = SkipTime;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)timeCountDown{
    _countTime--;
    [self.skipBtn setTitle:[NSString stringWithFormat:@"跳过%ld%@",(long)_countTime,@"s"] forState:UIControlStateNormal];
    if (_countTime == 0) {
        [self goToMainPage];
    }
}

-(void)goToMainPage{
    ViewController *vc = [[ViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - UIScrollViewDelagate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageControl.currentPage = _scrollView.contentOffset.x/kScreenWidth;
    if (_scrollView.contentOffset.x >1.5 * kScreenWidth) {
        _pageControl.hidden = YES;
    } else {
        _pageControl.hidden = NO;
    }
}

#pragma mark - setter/getter
-(UIButton *)enterBtn{
    if (!_enterBtn) {
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"HELPER_BUTTON"] forState:UIControlStateNormal];
        _enterBtn.frame = CGRectMake(0, kScreenHeight-60, kScreenWidth/2, 50);
        _enterBtn.centerX = kScreenWidth/2;
        [_enterBtn setTitle:@"立即进入" forState:UIControlStateNormal];
        [_enterBtn addTarget:self action:@selector(goToMainPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterBtn;
}

-(UIButton *)skipBtn{
    if (!_skipBtn) {
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.frame = CGRectMake(kScreenWidth-100-10, 30, 100, 40);
        _skipBtn.backgroundColor = [UIColor lightGrayColor];
        _skipBtn.layer.cornerRadius = 5;
        _skipBtn.layer.masksToBounds = YES;
        [_skipBtn setTitle:[NSString stringWithFormat:@"跳过%d%@",SkipTime,@"s"] forState:UIControlStateNormal];
        [_skipBtn addTarget:self action:@selector(goToMainPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipBtn;
}

-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCountDown) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(void)dealloc{
    NSLog(@"执行那个没");
    NSLog(@"执");
}

@end
