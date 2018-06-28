//
//  ViewController.m
//  Pthread_NSThread_Demo
//
//  Created by cs on 2018/6/27.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@end

@implementation ViewController {
    UIImageView *_imgView;
    int _ticketSurplusCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawUI];
    // Do any additional setup after loading the view, typically from a nib.
//    [self createThread];
//    [self createAutoThread];
//    [self createPrivacyThread];
//    [self downloadImageOnSubThread];
//    [self initTicketStatusNotSave];
    [self initTicketStatusSave];
}

- (void)drawUI {
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _imgView.center = self.view.center;
    [self.view addSubview:_imgView];
}

- (void)createThread {
    // 创建线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    // 启动线程
    [thread start];
}

- (void)run {
    NSLog(@"%@", [NSThread currentThread]);
}

- (void)createAutoThread {
    // 创建线程后自动启动线程
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void)createPrivacyThread {
    // 隐式创建并启动线程
    [self performSelector:@selector(run) withObject:nil];
}

/**
 创建一个线程下载图片
 */
- (void)downloadImageOnSubThread {
    // 在创建的子线程中调用downloadImage下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}

/**
 下载图片操作
 */
- (void)downloadImage {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    
    // 1. 获取图片 imageUrl
    NSURL *imageUrl = [NSURL URLWithString:@"https://ysc-demo-1254961422.file.myqcloud.com/YSC-phread-NSThread-demo-icon.jpg"];
    
    // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    // 通过二进制 data 创建 image
    UIImage *image = [UIImage imageWithData:imageData];
    
    // 3. 回到主线程进行图片赋值和界面刷新
    [self performSelectorOnMainThread:@selector(refreshOnMainThread:) withObject:image waitUntilDone:YES];
}

/**
 回到主线程刷新图片

 @param image 图片
 */
- (void)refreshOnMainThread:(UIImage *)image {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    
    // 赋值图片到imageview
    _imgView.image = image;
}

/**
 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    _ticketSurplusCount = 50;
    
    // 设置广州窗口卖票线程
    NSThread *ticketSaleWindow1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    ticketSaleWindow1.name = @"广州火车票售票窗口";
    
    // 设置龙岩窗口卖票线程
    NSThread *ticketSaleWindow2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    ticketSaleWindow2.name = @"龙岩火车票售票窗口";
    
    // 开始售卖火车票
    [ticketSaleWindow1 start];
    [ticketSaleWindow2 start];
}

/**
 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        //如果还有票，继续售卖
        if (_ticketSurplusCount > 0) {
            _ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", _ticketSurplusCount, [NSThread currentThread].name]);
            [NSThread sleepForTimeInterval:0.2];
        } else {  //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    _ticketSurplusCount = 50;
    
    // 设置广州窗口卖票线程
    NSThread *ticketSaleWindow1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    ticketSaleWindow1.name = @"广州火车票售票窗口";
    
    // 设置龙岩窗口卖票线程
    NSThread *ticketSaleWindow2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    ticketSaleWindow2.name = @"龙岩火车票售票窗口";
    
    // 开始售卖火车票
    [ticketSaleWindow1 start];
    [ticketSaleWindow2 start];
}

/**
 售卖火车票(非线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 互斥锁
        @synchronized(self) {
            //如果还有票，继续售卖
            if (_ticketSurplusCount > 0) {
                _ticketSurplusCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", _ticketSurplusCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            } else {  //如果已卖完，关闭售票窗口
                NSLog(@"所有火车票均已售完");
                break;
            }
        }
    }
}


@end
