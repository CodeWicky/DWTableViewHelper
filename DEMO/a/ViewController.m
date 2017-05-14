//
//  ViewController.m
//  a
//
//  Created by Wicky on 2017/5/6.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWTableViewHelper.h"
#import "DWAnimationHeader.h"
#import "ACell.h"
#import "BCell.h"


@interface ViewController ()<DWTableViewHelperDelegate>

@property (nonatomic ,strong) UITableView * tabV;

@property (nonatomic ,strong) DWTableViewHelper * helper;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataArr];
    [self.view addSubview:self.tabV];
}

-(void)initDataArr {
    
    NSArray * temp = @[@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",];
    for (NSString * str in temp) {
        AModel * model = [AModel new];
        model.title = str;
        [self.dataArr addObject:model];
    }
    
    BModel * model = [BModel new];
    model.title = @"asdf";
    model.cellRowHeight = 100;
    [self.dataArr addObject:model];
    
    BModel * newM = [BModel new];
    newM.title = @"new Model";
    newM.loadCellFromNib = YES;
    newM.cellClassStr = @"CCell";
    newM.cellID = @"IDIDI";
    [self.dataArr addObject:newM];
}

-(id)dw_TableView:(UITableView *)tableView showAnimationWithCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[DWAnimation alloc] initAnimationWithLayer:nil animationKey:@"animation" animationCreater:^(DWAnimationMaker *maker) {
        maker.scaleFrom(0).scaleTo(1).duration(0.4).install();
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableView *)tabV {
    if (!_tabV) {
        _tabV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 414, 500) style:(UITableViewStyleGrouped)
                 ];
        self.helper = [[DWTableViewHelper alloc] initWithTabV:_tabV dataSource:self.dataArr];
        self.helper.useAutoRowHeight = YES;
        [self.helper setTheSeperatorToZero];
        self.helper.minAutoRowHeight = 55;
        self.helper.helperDelegate = self;
        self.helper.loadDataMode = DWTableViewHelperLoadDataLazyMode;
        self.helper.ignoreCount = 1;
    }
    return _tabV;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.helper.selectEnable = !self.helper.selectEnable;
}

-(NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
