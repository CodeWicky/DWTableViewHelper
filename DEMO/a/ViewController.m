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


@interface ViewController ()<DWTableViewHelperDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView * tabV;

@property (nonatomic ,strong) DWTableViewHelper * helper;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataArr];
    [self.view addSubview:self.tabV];
    UIImageView * v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 414, 221)];
    v.image = [UIImage imageNamed:@"timg.jpg"];
    [self.helper setAutoZoomHeader:v scrollHandler:^(CGFloat contentoffset) {
        NSLog(@"%f",contentoffset);
    }];
}

-(void)initDataArr {
    
    NSArray * temp = @[@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjklasdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",@"asdf",@"sdfgfdfgsdfsdfgsdfd",@"asdfgfrfvcfsdkmnfgs,nmn,dfj;Zjsflvnkjdskfmfdlasjknmf,mdfkkjdslfdkkl;dfkvflksmndfflk,,skdfklfkkjlkfjdkjelkfjdklkkjkl",@"afda",];
//    NSArray * temp = @[@"asd"];
    for (NSString * str in temp) {
        AModel * model = [AModel new];
        model.title = str;
        model.useAutoRowHeight = YES;
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
    
    
    NSLog(@"%f",UITableViewAutomaticDimension);
    
}

-(id)dw_tableView:(UITableView *)tableView showAnimationWithCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[DWAnimation alloc] initAnimationWithLayer:nil animationKey:@"animation" animationCreater:^(DWAnimationMaker *maker) {
        maker.scaleFrom(0).scaleTo(1).duration(0.4).install();
    }];
}

-(DWTableViewHelperCell *)dw_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWTableViewHelperModel * model = [self.helper modelFromIndexPath:indexPath];
    DWTableViewHelperCell * cell = [self.helper dequeueReusableCellWithModel:model];
    return cell;
}

-(UITableView *)tabV {
    if (!_tabV) {
        _tabV = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 414, 500) style:(UITableViewStylePlain)
                 ];
        self.helper = [[DWTableViewHelper alloc] initWithTabV:_tabV dataSource:self.dataArr];
//        self.helper.useAutoRowHeight = YES;
        [self.helper setTheSeperatorToZero];
//        self.helper.minAutoRowHeight = 55;
        self.helper.helperDelegate = self;
        [self.helper enableTableViewContentInsetAutoAdjust:NO inViewController:nil];
        
//        self.helper.loadDataMode = DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode;
//        self.helper.ignoreCount = 1;
//        [_tabV registerClass:[ACell class] forCellReuseIdentifier:@"cellID"];
    }
    return _tabV;
}

//-(BOOL)dw_TableView:(UITableView *)tableView selectModeWillSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.helper setSelect:YES indexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0]]];
//    return YES;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.label.text = @"as";
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
//
//
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.helper setAutoZoomHeader:nil scrollHandler:nil];
}

-(NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
