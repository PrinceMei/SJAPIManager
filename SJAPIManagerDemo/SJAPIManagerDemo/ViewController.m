//
//  ViewController.m
//  SJAPIManagerDemo
//
//  Created by sharejoy_lx on 16-06-24.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import "ViewController.h"
#import "TestAPI.h"

@interface ViewController () <SJAPIManagerCallBackDelegate>

@property (nonatomic, strong) TestAPI *testApi;

@end

@implementation ViewController

- (TestAPI *)testApi
{
    if (!_testApi) {
        _testApi = [[TestAPI alloc] init];
        _testApi.delegate = self;
    }
    return _testApi;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(200, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(loadNew) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(200, 250, 100, 100)];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

- (void)loadNew {
    self.testApi.isLoadNew=YES;
    [self.testApi loadData];
}

- (void)loadMore {
    self.testApi.isLoadNew=NO;
    [self.testApi loadData];
}

- (void)managerCallAPIDidSuccess:(SJAPIBaseManager *)manager {
    if ([manager isKindOfClass:[TestAPI class]]) {
        TestAPI *testApi = (TestAPI *)manager;
        NSLog(@"请求成功 code: %d ", testApi.code);
        
    }
}

- (void)managerCallAPIDidFailed:(SJAPIBaseManager *)manager {
    NSLog(@"请求失败");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
