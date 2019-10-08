//
//  DWTableViewHelper.m
//  DWTableViewHelper
//
//  Created by Wicky on 2017/1/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWTableViewHelper.h"
#import <DWKit/DWOperationCancelFlag.h>
#import <DWKit/DWTransaction.h>

#define SeperatorColor [UIColor lightGrayColor]

#define DWRespondTo(arr) \
SEL selec = DWTransSEL(_cmd,@"dw_",0);\
if (self.helperDelegate && [self.helperDelegate respondsToSelector:selec]) {\
id target = self.helperDelegate;\
NSMethodSignature  *signature = [[target class] instanceMethodSignatureForSelector:selec];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
invocation.target = target;\
invocation.selector = selec;\
__block int i = 2;\
[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {\
[invocation setArgument:&obj atIndex:i];\
i++;\
}];\
[invocation invoke];\
return;\
}\


#define DWRespond \
({\
SEL selec = DWTransSEL(_cmd,@"dw_",0);\
(self.helperDelegate && [self.helperDelegate respondsToSelector:selec]);\
})


#define DWUpperFirstChar(str) \
({\
NSString * strT = [str substringToIndex:1];\
strT = strT.uppercaseString;\
strT = [NSString stringWithFormat:@"%@%@",strT,[str substringFromIndex:1]];\
strT;})


#define DWTransSEL(target,paraStr,index) \
({\
NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"[:]" options:0 error:0];\
NSString * targetStr = NSStringFromSelector(target);\
NSArray * arr = [regex matchesInString:targetStr options:0 range:NSMakeRange(0, targetStr.length)];\
if (arr.count == 0) {\
targetStr = [targetStr stringByAppendingString:DWUpperFirstChar(paraStr)];\
}\
else\
{\
if (index == 0) {\
targetStr = [paraStr stringByAppendingString:DWUpperFirstChar(targetStr)];\
} else if (index >= arr.count) {\
targetStr = [targetStr stringByAppendingString:paraStr];\
} else {\
NSRange range = [[arr[index - 1] valueForKey:@"range"] rangeValue];\
range = NSMakeRange(range.location + 1, 0);\
targetStr = [targetStr stringByReplacingCharactersInRange:range withString:paraStr];\
}\
}\
NSSelectorFromString(targetStr);\
})


#define DWDelegate self.helperDelegate



static UIImage * ImageNull = nil;

@interface DWTableViewHelper ()<UITableViewDelegate,UITableViewDataSource,UITableViewDataSourcePrefetching>
{
    BOOL hasPlaceHolderView;
}

///当前tableView
@property (nonatomic ,strong) UITableView * tabV;

///上一个选择的idxP
@property (nonatomic ,strong) NSIndexPath * lastSelected;

///计算用cell字典
@property (nonatomic ,strong) NSMutableDictionary * dic4CalCell;

///是否在滚向头部
@property (nonatomic ,assign) BOOL isScrollingToTop;

///需要加载的idxPs
@property (nonatomic ,strong) NSMutableArray * data2Load;

///进程打断工具类
@property (nonatomic ,strong) DWOperationCancelFlag * flag;

///自动缩放头视图回调
@property (nonatomic ,copy) void(^autoZoomHeaderHandler)(CGFloat contentoffset);

//自动缩放头视图模式
@property (nonatomic ,assign) BOOL autoZoomHeaderMode;

@property (nonatomic ,strong) UIView * autoZoomHeader;

@property (nonatomic ,assign) CGRect autoZoomOriFrm;

@end

@interface DWTableViewHelperModel ()

@property (nonatomic ,strong) UIImage * cellSnap;

@end

@implementation DWTableViewHelper
static DWTableViewHelperModel * PlaceHolderCellModelAvoidCrashing = nil;

@synthesize cellClassStr,cellID,cellRowHeight,cellEditSelectedIcon,cellEditUnselectedIcon;

-(instancetype)initWithTabV:(__kindof UITableView *)tabV dataSource:(NSArray *)dataSource
{
    self = [super init];
    if (self) {
        _tabV = tabV;
        tabV.delegate = self;
        tabV.dataSource = self;
        if (@available(iOS 10.0,*)) {
            tabV.prefetchDataSource = self;
        }
        _dataSource = dataSource;
        _multiSection = NO;
        self.cellRowHeight = -1;
        _selectEnable = tabV.editing;
        _minAutoRowHeight = -1;
        _maxAutoRowHeight = -1;
        _flag = [DWOperationCancelFlag new];
    }
    return self;
}

-(__kindof DWTableViewHelperModel *)modelFromIndexPath:(NSIndexPath *)indexPath {
    id obj = nil;
    if (self.multiSection) {
        obj = self.dataSource[indexPath.section];
        if (![obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld of dataSource is not kind of NSArray but %@",indexPath.section,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[DWTableViewHelperModel class]]) {
                return obj;
            }
            return nil;
        }
        obj = self.dataSource[indexPath.section][indexPath.row];
        if (![obj isKindOfClass:[DWTableViewHelperModel class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld row %ld of dataSource is not kind of DWTableViewHelperModel but %@",indexPath.section,indexPath.row,NSStringFromClass([obj class]));
            obj = PlaceHolderCellModelAvoidCrashingGetter();
        }
    }
    else
    {
        obj = self.dataSource[indexPath.row];
        if (![obj isKindOfClass:[DWTableViewHelperModel class]]) {
            NSAssert(NO, @"you set to not use multiSection but the obj in row %ld of dataSource is not kind of DWTableViewHelperModel but %@",indexPath.row,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[NSArray class]] && [obj count] > 0 && [[obj firstObject] isKindOfClass:[DWTableViewHelperModel class]]) {
                obj = [obj firstObject];
            } else {
                obj = PlaceHolderCellModelAvoidCrashingGetter();
            }
        }
    }
    return obj;
}

-(DWTableViewHelperCell *)dequeueReusableCellWithModel:(__kindof DWTableViewHelperModel *)model {
    if (!model) {
        return nil;
    }
    return [self createCellFromModel:model useReuse:YES];
}

-(void)handleLoadDataWithCell:(__kindof DWTableViewHelperCell *)cell indexPath:(NSIndexPath *)indexPath model:(__kindof DWTableViewHelperModel *)model {
    if (!cell || !indexPath || !model) {
        return;
    }
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [self ignoreModeLoadCell:cell indexPath:indexPath model:model];
    } else if (self.loadDataMode == DWTableViewHelperLoadDataLazyMode) {
        [self lazyModeLoadCell:cell indexPath:indexPath model:model];
    } else {
        cell.model = model;
    }
}

-(void)setTheSeperatorToZero {
    [self.tabV setSeparatorInset:UIEdgeInsetsZero];
}

-(void)reloadDataAndHandlePlaceHolderView
{
    __weak typeof(self)weakSelf = self;
    [self reloadDataWithCompletion:^{
        ///修复reload前判断是否存在数据引起的处理错误
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
        handlePlaceHolderView(weakSelf.placeHolderView, weakSelf.tabV, ![weakSelf caculateHaveData], &hasPlaceHolderView);
#pragma clang diagnostic pop
    }];
}

-(void)reloadDataWithCompletion:(dispatch_block_t)completion
{
    if (!completion) {
        [self.tabV reloadData];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabV reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)showPlaceHolderView {
    handlePlaceHolderView(self.placeHolderView, self.tabV, YES, &hasPlaceHolderView);
}

-(void)hidePlaceHolderView {
    handlePlaceHolderView(self.placeHolderView, self.tabV, NO, &hasPlaceHolderView);
}

-(void)setAllSelect:(BOOL)select {
    NSUInteger count = self.tabV.numberOfSections;
    if (select) {
        for (int i = 0; i < count; i++) {
            [self setSection:i allSelect:select];
        }
    }
    else
    {
        [self.tabV reloadData];
    }
}

-(void)setSection:(NSUInteger)section allSelect:(BOOL)select {
    NSUInteger count = self.tabV.numberOfSections;
    if (section >= count) {
        return;
    }
    NSUInteger rows = [self.tabV numberOfRowsInSection:section];
    if (select) {
        for (int i = 0; i < rows; i++) {
            [self.tabV selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else
    {
        for (int i = 0; i < rows; i++) {
            [self.tabV deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO];
        }
    }
}

-(void)setSelect:(BOOL)select indexPaths:(NSArray <NSIndexPath *>*)indexPaths {
    if (select) {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.selectedRows containsObject:obj] && [self validateIndexPath:obj]) {
                [self.tabV selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }];
    } else {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.selectedRows containsObject:obj] && [self validateIndexPath:obj]) {
                [self.tabV deselectRowAtIndexPath:obj animated:NO];
            }
        }];
    }
}

-(NSArray<NSIndexPath *> *)indexPathsBetween:(NSIndexPath *)idxPA and:(NSIndexPath *)idxPB {
    if (![self validateIndexPath:idxPA] || ![self validateIndexPath:idxPB]) {
        return nil;
    }
    NSUInteger dis = [self distanceBetweenIndexPathA:idxPB indexPathB:idxPA];
    NSMutableArray * arr = @[idxPA].mutableCopy;
    if (dis) {
        [arr addObjectsFromArray:[self indexPathsAroundIndexPath:idxPA nextOrPreivious:YES count:dis step:1]];
    }
    return arr;
}

-(void)invertSelectSection:(NSUInteger)section
{
    NSUInteger count = self.tabV.numberOfSections;
    if (section >= count) {
        return;
    }
    NSUInteger rows = [self.tabV numberOfRowsInSection:section];
    NSMutableArray * arr = filterArray(self.selectedRows, ^BOOL(NSIndexPath * obj, NSUInteger idx, NSUInteger count, BOOL *stop) {
        return obj.section == section;
    });
    for (int i = 0; i < rows; i++) {
        __block BOOL select = NO;
        __block NSIndexPath * idxP;
        [arr enumerateObjectsUsingBlock:^(NSIndexPath * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.row == i) {
                select = YES;
                idxP = obj;
                *stop = YES;
            }
        }];
        
        if (idxP) {
            [arr removeObject:idxP];
        }
        
        if (select) {
            [self.tabV deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO];
        }
        else
        {
            [self.tabV selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

-(void)invertSelectAll
{
    NSUInteger count = self.tabV.numberOfSections;
    for (int i = 0; i < count; i++) {
        [self invertSelectSection:i];
    }
}

-(void)enableTableViewContentInsetAutoAdjust:(BOOL)autoAdjust inViewController:(UIViewController *)vc {
    if (@available(iOS 11.0,*)) {
        _tabV.contentInsetAdjustmentBehavior = autoAdjust?UIScrollViewContentInsetAdjustmentAutomatic:UIScrollViewContentInsetAdjustmentNever;
    } else {
        vc.automaticallyAdjustsScrollViewInsets = autoAdjust;
    }
}

-(void)fixRefreshControlInsets {
    if (@available(iOS 11.0,*)) {
        _tabV.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tabV.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
        _tabV.scrollIndicatorInsets = _tabV.contentInset;
    }
}

-(void)setAutoZoomHeader:(UIView *)header scrollHandler:(void (^)(CGFloat))handler {
    
    if (header == nil) {
        [self removeAutoZoomHeader];
        return;
    }
    
    ///添加容器层，保证header在边缘处被剪切
    UIView * container = [[UIView alloc] initWithFrame:_tabV.frame];
    container.backgroundColor = _tabV.backgroundColor;
    container.clipsToBounds = YES;
    UIView * superView = _tabV.superview;
    [superView insertSubview:container belowSubview:_tabV];
    _tabV.frame = _tabV.bounds;
    [container addSubview:_tabV];

    ///添加占位视图
    CGRect headerBounds = header.bounds;
    headerBounds.size.width = _tabV.bounds.size.width;
    UIView * placeHolder = [[UIView alloc] initWithFrame:headerBounds];
    _tabV.tableHeaderView = placeHolder;
    _tabV.backgroundColor = [UIColor clearColor];
    
    ///添加头视图
    header.frame = header.bounds;
    [container insertSubview:header belowSubview:_tabV];
    
    ///设置相关值
    self.autoZoomHeader = header;
    self.autoZoomHeaderHandler = handler;
    self.autoZoomOriFrm = header.bounds;
    self.autoZoomHeaderMode = YES;
}

-(void)removeAutoZoomHeader {
    if (self.autoZoomHeaderMode) {
        
        ///放回原父视图
        UIView * container = _tabV.superview;
        UIView * superView = container.superview;
        CGRect containerFrm = _tabV.superview.frame;
        _tabV.frame = containerFrm;
        [superView insertSubview:_tabV belowSubview:container];
        
        ///移除容器层及头视图
        [container removeFromSuperview];
        _tabV.tableHeaderView = nil;
        
        ///恢复默认值
        self.autoZoomHeaderMode = NO;
        self.autoZoomHeader = nil;
        self.autoZoomHeaderHandler = nil;
        self.autoZoomOriFrm = CGRectNull;
    }
}

-(void)setAllNeedsReAutoCalculateRowHeight {
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setObjNeedsReAutoCalculateRowHeight:obj];
    }];
}

-(void)setObjNeedsReAutoCalculateRowHeight:(id)anObj {
    if ([anObj isKindOfClass:[NSArray class]]) {
        [((NSArray *)anObj) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self setObjNeedsReAutoCalculateRowHeight:obj];
        }];
    } else if ([anObj isKindOfClass:[DWTableViewHelperModel class]]) {
        [((__kindof DWTableViewHelperModel *)anObj) setNeedsReAutoCalculateRowHeight];
    }
}

#pragma mark --- delegate Map Start ---
///display
-(void)tableView:(UITableView *)tableView willDisplayCell:(DWTableViewHelperCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellEditSelectedIcon && cell.model.cellEditSelectedIcon == ImageNull) {
        cell.model.cellEditSelectedIcon = self.cellEditSelectedIcon;
    }
    if (self.cellEditUnselectedIcon && cell.model.cellEditUnselectedIcon == ImageNull) {
        cell.model.cellEditUnselectedIcon = self.cellEditUnselectedIcon;
    }
    
    [self handleCellShowAnimationWithTableView:tableView cell:cell indexPath:indexPath];
    
    DWRespondTo(DWParas(tableView,cell,indexPath,nil));
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    DWRespondTo(DWParas(tableView,cell,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

///height
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///即使外部设置代理，若外部返回小于0则认为外部不想设置此cell，则有框架按内部规则计算。否则按外部返回值为准。
    CGFloat height = -1;
    if (DWRespond) {
        height = [DWDelegate dw_TableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    if (height >= 0) {
        return height;
    }
    
    DWTableViewHelperModel * model = [self modelFromIndexPath:indexPath];
    if (model.cellRowHeight >= 0) {
        return model.cellRowHeight;
    }
    if (self.cellRowHeight >= 0) {
        return self.cellRowHeight;
    }
    if (self.useAutoRowHeight) {//返回放回自动计算的行高
        return [self autoCalculateRowHeightWithModel:model];
    }
    if (self.tabV.rowHeight >= 0) {
        return self.tabV.rowHeight;
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = -1;
    if (DWRespond) {
        height = [DWDelegate dw_TableView:tableView heightForHeaderInSection:section];
    }
    
    if (height >= 0) {
        return height;
    }
    
    if (self.helperDelegate && [self.helperDelegate respondsToSelector:@selector(dw_TableView:viewForHeaderInSection:)]) {
        return [self.helperDelegate dw_TableView:tableView viewForHeaderInSection:section].bounds.size.height;
    }
    if (@available(iOS 11, *)) {
        return 0;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = -1;
    if (DWRespond) {
        height = [DWDelegate dw_TableView:tableView heightForFooterInSection:section];
    }
    
    if (height >= 0) {
        return height;
    }
    
    if (self.helperDelegate && [self.helperDelegate respondsToSelector:@selector(dw_TableView:viewForFooterInSection:)]) {
        return [self.helperDelegate dw_TableView:tableView viewForFooterInSection:section].bounds.size.height;
    }
    if (@available(iOS 11, *)) {
        return 0;
    }
    return 0.01;
}

///sectionHeader、sectionFooter
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

///accessory
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///highlight
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///选中
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectEnable && DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:selectModeWillSelectRowAtIndexPath:)] && [DWDelegate dw_TableView:self.tabV selectModeWillSelectRowAtIndexPath:indexPath]) {///选中模式下将要选中
        return nil;
    }
    
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectEnable && DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:selectModeWillDeselectRowAtIndexPath:)] && [DWDelegate dw_TableView:self.tabV selectModeWillDeselectRowAtIndexPath:indexPath]) {///选中模式下将要选中
        return nil;
    }
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectEnable && DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:selectModeWillSelectRowAtIndexPath:)] && [DWDelegate dw_TableView:tableView selectModeWillSelectRowAtIndexPath:indexPath]) {///选择模式下且实现了选择方法
        return;
    }
    if (self.selectEnable) {
        if (!self.multiSelect && self.lastSelected) {
            [tableView deselectRowAtIndexPath:self.lastSelected animated:NO];
        }
        self.lastSelected = indexPath;
        return;
    }
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectEnable && DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:selectModeWillDeselectRowAtIndexPath:)] && [DWDelegate dw_TableView:self.tabV selectModeWillDeselectRowAtIndexPath:indexPath]) {///选中模式下将要取消选中
        return;
    }
    if (self.selectEnable) {
        self.lastSelected = nil;
        return;
    }
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

///editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectEnable) {
        return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    }
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    
    return @"Delete";
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    DWRespondTo(DWParas(tableView,indexPath,nil));
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return YES;
}

///indentation
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return 0;
}

///copy / paste
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
///focus
- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 9.0,*)) {
        if (DWRespond) {
            return [DWDelegate dw_TableView:tableView canFocusRowAtIndexPath:indexPath];
        }
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context {
    if (@available(iOS 9.0,*)) {
        if (DWRespond) {
            return [DWDelegate dw_TableView:tableView shouldUpdateFocusInContext:context];
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    if (@available(iOS 9.0,*)) {
        DWRespondTo(DWParas(tableView,context,coordinator,nil));
    }
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView {
    if (@available(iOS 9.0,*)) {
        if (DWRespond) {
            return [DWDelegate dw_IndexPathForPreferredFocusedViewInTableView:tableView];
        }
    }
    return nil;
}
#pragma clang diagnostic pop


///dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = -1;
    if (DWRespond) {
        number = [DWDelegate dw_TableView:tableView numberOfRowsInSection:section];
    }
    
    if (number >= 0) {
        return number;
    }
    
    if (self.multiSection) {
        id obj = self.dataSource[section];
        if (![obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"you set to use multiSection but the obj in section %ld of dataSource is not kind of NSArray but %@",section,NSStringFromClass([obj class]));
            if ([obj isKindOfClass:[DWTableViewHelperModel class]]) {
                return 1;
            }
            return 0;
        }
        return [[self.dataSource objectAtIndex:section] count];
    }
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWTableViewHelperCell * cell = nil;
    DWTableViewHelperModel * model = [self modelFromIndexPath:indexPath];
    if (DWRespond) {
        cell = [DWDelegate dw_TableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if (!cell) {
        cell = [self createCellFromModel:model useReuse:YES];
    }
    [self handleLoadDataWithCell:cell indexPath:indexPath model:model];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger number = -1;
    if (DWRespond) {
        number = [DWDelegate dw_NumberOfSectionsInTableView:tableView];
    }
    
    if (number >= 0) {
        return number;
    }
    
    if (self.multiSection) {
        return self.dataSource.count;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView titleForFooterInSection:section];
    }
    return nil;
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (DWRespond) {
        return [DWDelegate dw_SectionIndexTitlesForTableView:tableView];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (DWRespond) {
        return [DWDelegate dw_TableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return index;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespond) {
        [DWDelegate dw_TableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    DWRespondTo(DWParas(tableView,sourceIndexPath,destinationIndexPath,nil));
}

///prefetch
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    DWRespondTo(DWParas(tableView,indexPaths,nil));
}

- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    DWRespondTo(DWParas(tableView,indexPaths,nil));
}

///scroll
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ///自动缩放模式
    if (self.autoZoomHeaderMode && self.autoZoomHeader) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGRect desFrm = self.autoZoomOriFrm;
        if (offsetY >= 0) {
            if (desFrm.size.height - offsetY >= 0) {
                desFrm.origin.y = -offsetY;
            } else {
                desFrm.origin.y = -desFrm.size.height;
            }
        } else {
            CGFloat height = desFrm.size.height - offsetY;
            CGFloat width = desFrm.size.width * 1.0 / desFrm.size.height * height;
            CGFloat originX = (desFrm.size.width - width) / 2.0;
            desFrm.size.width = width;
            desFrm.size.height = height;
            desFrm.origin.x = originX;
        }
        self.autoZoomHeader.frame = desFrm;
        if (self.autoZoomHeaderHandler) {
            self.autoZoomHeaderHandler(offsetY);
        }
    }
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [self ignoreModeReload];
        [self.data2Load removeAllObjects];
    }
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [self handleData2LoadWithVelocity:velocity targetContentOffset:*targetContentOffset];
    }
    if (DWRespond) {
        [DWDelegate dw_ScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.loadDataMode == DWTableViewHelperLoadDataLazyMode && !decelerate) {
        [self lazyModeReload];
    }
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode && !decelerate) {//高速截图模式下提交截图任务
        [self commitSnapTransaction];
    }
    if (DWRespond) {
        [DWDelegate dw_ScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.loadDataMode == DWTableViewHelperLoadDataLazyMode) {
        [self lazyModeReload];
    }
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [self commitSnapTransaction];
    }
    DWRespondTo(DWParas(scrollView,nil));
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        self.isScrollingToTop = NO;
        [self ignoreModeReload];
    }
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [self commitSnapTransaction];
    }
    if (self.loadDataMode == DWTableViewHelperLoadDataLazyMode) {
        [self lazyModeReload];
    }
    DWRespondTo(DWParas(scrollView,nil));
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (DWRespond) {
        return [DWDelegate dw_ViewForZoomingInScrollView:scrollView];
    }
    return nil;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (DWRespond) {
        return [DWDelegate dw_ScrollViewWillBeginZooming:scrollView withView:view];
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (DWRespond) {
        [DWDelegate dw_ScrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    BOOL should = YES;
    if (DWRespond) {
        should = [DWDelegate dw_ScrollViewShouldScrollToTop:scrollView];
    }
    if (should && self.loadDataMode != DWTableViewHelperLoadDataDefaultMode) {
        self.isScrollingToTop = YES;
    }
    return should;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        self.isScrollingToTop = NO;
        [self ignoreModeReload];
    } else if (self.loadDataMode == DWTableViewHelperLoadDataLazyMode) {
        self.isScrollingToTop = NO;
        [self lazyModeReload];
    }
    DWRespondTo(DWParas(scrollView,nil));
}

#pragma mark --- delegate Map End ---

#pragma mark --- tool Method ---
-(BOOL)caculateHaveData {
    NSInteger count = 0;
    if (self.multiSection) {
        NSInteger sections = self.tabV.numberOfSections;
        for (int i = 0; i < sections; i++) {
            count += [self.tabV numberOfRowsInSection:i];
        }
    } else {
        count = [self.tabV numberOfRowsInSection:0];
    }
    return count > 0 ? YES : NO;
}

-(BOOL)validateIndexPath:(NSIndexPath *)idxP {
    if (self.tabV.dataSource == nil) {
        NSAssert(NO, @"you dataSource is nil so we can't calculate the distance.");
        return NO;
    }
    if (idxP.section >= self.tabV.numberOfSections) {
        return NO;
    }
    if (idxP.row >= [self.tabV numberOfRowsInSection:idxP.section]) {
        return NO;
    }
    return YES;
}

-(CGFloat)autoCalculateRowHeightWithModel:(__kindof DWTableViewHelperModel *)model {
    if (model.autoCalRowHeight >= 0) {
        return model.autoCalRowHeight;
    }
    __kindof DWTableViewHelperCell * cell = [self createCellFromModel:model useReuse:NO];
    [cell prepareForReuse];
    cell.model = model;
    cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat calRowHeight = [self calculateCellHeightWithCell:cell];
    if (self.maxAutoRowHeight > 0 || self.minAutoRowHeight > 0) {
        if (self.maxAutoRowHeight > 0 && self.minAutoRowHeight > 0 && self.maxAutoRowHeight < self.minAutoRowHeight) {
            NSAssert(NO, @"wrong autoRowHeight limit with maximum %.2f and minimum %.2f",self.maxAutoRowHeight,self.minAutoRowHeight);
        } else {
            if ((self.minAutoRowHeight > 0) && calRowHeight < self.minAutoRowHeight) {
                calRowHeight = self.minAutoRowHeight;
            } else if ((self.maxAutoRowHeight > 0) && (self.maxAutoRowHeight < calRowHeight)) {
                calRowHeight = self.maxAutoRowHeight;
            }
        }
    }
    if (calRowHeight >= 0) {
        model.autoCalRowHeight = calRowHeight;
    }
    return model.autoCalRowHeight;
}

///根据cell计算cell的高度（代码源自FDTemplateLayoutCell）
-(CGFloat)calculateCellHeightWithCell:(UITableViewCell *)cell
{
    CGFloat width = self.tabV.bounds.size.width;
    
    if (width <= 0) {
        return -1;
    }
    
    CGRect cellBounds = cell.bounds;
    cellBounds.size.width = width;
    cell.bounds = cellBounds;
    CGFloat accessoryViewWidth;
    
    for (UIView *view in self.tabV.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
            accessoryViewWidth = view.bounds.size.width;
            break;
        }
    }
    
    //根据辅助视图校正width
    if (cell.accessoryView) {
        accessoryViewWidth = (cell.accessoryView.bounds.size.width + 16);
    }
    else
    {
        static const CGFloat accessoryWidth[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        accessoryViewWidth = accessoryWidth[cell.accessoryType];
    }
    
    if ([UIScreen mainScreen].scale >= 3 && [UIScreen mainScreen].bounds.size.width >= 414) {
        accessoryViewWidth += 4;
    }
    
    width -= accessoryViewWidth;
    CGFloat height = 0;
    if (width > 0) {//如果不是非自适应模式则添加约束后计算约束后高度
        NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
        
        // iOS10.2以后，cell的contentView会额外添加一条宽度为0的约束。通过给他添加上下左右的约束来是此约束失效
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) {
            ///为了避免冲突，修改优先级为optional
             widthConstraint.priority = UILayoutPriorityRequired - 1;
            
            ///添加4个约束
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:accessoryViewWidth];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        [cell.contentView addConstraint: widthConstraint];
        
        ///根据约束计算高度
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        //移除额外添加的约束
        [cell.contentView removeConstraint: widthConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {
            [cell removeConstraints:edgeConstraints];
        }
    }
    if (height == 0) {//如果约束错误可能导致计算结果为零，则以自适应模式再次计算
        height = [cell sizeThatFits:CGSizeMake(width, 0)].height;
    }
    if (height == 0) {//如果计算仍然为0，则给出默认高度
        height = 44;
    }
    if (self.tabV.separatorStyle != UITableViewCellSeparatorStyleNone) {//如果不为无分割线模式则添加分割线高度
        height += 1.0 /[UIScreen mainScreen].scale;
    }
    return height;
}

-(__kindof DWTableViewHelperCell *)createCellFromModel:(DWTableViewHelperModel *)model useReuse:(BOOL)useReuse {
    NSString * cellIDTemp;
    NSString * aCellClassStr;
    if (model.cellClassStr.length && model.cellID.length) {
        cellIDTemp = model.cellID;
        aCellClassStr = model.cellClassStr;
    } else if (self.cellClassStr.length && self.cellID.length) {
        cellIDTemp = self.cellID;
        aCellClassStr = self.cellClassStr;
    } else {
        NSAssert(NO, @"cellClassStr and cellID must be set together at least one time in DWTableViewHelperModel or DWTableViewHelper");
        return nil;
    }
    __kindof DWTableViewHelperCell * cell = nil;
    if (useReuse) {
        cell = [self.tabV dequeueReusableCellWithIdentifier:cellIDTemp];
        if (cell) {
            return cell;
        }
    } else {
        cell = self.dic4CalCell[aCellClassStr];
        if (cell) {
            return cell;
        }
    }
    
    Class cellClass = NSClassFromString(aCellClassStr);
    if (!cellClass) {
        NSAssert(NO, @"cannot load a cellClass from %@,check the cellClassStr you have set",model.cellClassStr.length?model.cellClassStr:self.cellClassStr);
        return nil;
    }
    
    if (model.loadCellFromNib) {
        cell = [[NSBundle mainBundle] loadNibNamed:aCellClassStr owner:nil options:nil].lastObject;
        if (cell && !useReuse) {
            [cell setValue:@(YES) forKey:@"_just4Cal"];
            self.dic4CalCell[aCellClassStr] = cell;
        }
        return cell;
    }
    
    cell = [[cellClass alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIDTemp];
    if (cell && !useReuse) {
        [cell setValue:@(YES) forKey:@"_just4Cal"];
        self.dic4CalCell[aCellClassStr] = cell;
    }
    return cell;
}

-(void)handleCellShowAnimationWithTableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    ///处理动画
    BOOL needShow = YES;
    if (DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:shouldAnimationWithCell:forRowAtIndexPath:)]) {
        needShow = [DWDelegate dw_TableView:tableView shouldAnimationWithCell:cell forRowAtIndexPath:indexPath];
    }
    if (needShow) {
        id animation = nil;
        if (DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:showAnimationWithCell:forRowAtIndexPath:)]) {
            animation = [DWDelegate dw_TableView:tableView showAnimationWithCell:cell forRowAtIndexPath:indexPath];
        }
        if (!animation) {
            animation = self.cellShowAnimation;
        }
        if (animation) {
            if ([animation isKindOfClass:[CAAnimation class]]) {
                [cell.layer addAnimation:animation forKey:@"animation"];
            } else if ([animation isKindOfClass:NSClassFromString(@"DWAnimationAbstraction")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [animation performSelector:NSSelectorFromString(@"startAnimationWithContent:") withObject:cell];
#pragma clang diagnostic pop
            }
        }
    }
}

-(void)ignoreModeReload {
    if (self.isScrollingToTop) {
        return;
    }
    if (self.tabV.visibleCells.count == 0) {
        return;
    }
    for (__kindof DWTableViewHelperCell * cell in self.tabV.visibleCells) {
        NSIndexPath * idx = [self.tabV indexPathForCell:cell];
        DWTableViewHelperModel * model = [self modelFromIndexPath:idx];
        [self loadCell:cell model:model animated:NO];
    }
}

-(void)lazyModeReload {
    for (__kindof DWTableViewHelperCell * cell in self.tabV.visibleCells) {
        NSIndexPath * idx = [self.tabV indexPathForCell:cell];
        DWTableViewHelperModel * model = [self modelFromIndexPath:idx];
        [self loadCell:cell model:model animated:YES];
    }
}

-(void)handleData2LoadWithVelocity:(CGPoint)velocity targetContentOffset:(CGPoint)targetContentOffset {
    CGRect targerRect = CGRectMake(0, targetContentOffset.y, self.tabV.bounds.size.width, self.tabV.bounds.size.height);
    NSArray * targetIdxPs = [self.tabV indexPathsForRowsInRect:targerRect];
    NSInteger distance = [self distanceBetweenIndexPathA:targetIdxPs.firstObject indexPathB:self.tabV.indexPathsForVisibleRows.firstObject];
    NSUInteger ignoreCount = self.ignoreCount > 0 ? self.ignoreCount : 8;
    if (distance > ignoreCount) {
        if (velocity.y >= 0) {
            [self.data2Load addObjectsFromArray:[self indexPathsAroundIndexPath:targetIdxPs.firstObject nextOrPreivious:NO count:3 step:1]];
        }
        [self.data2Load addObjectsFromArray:targetIdxPs];
        if (velocity.y < 0) {
            [self.data2Load addObjectsFromArray:[self indexPathsAroundIndexPath:targetIdxPs.lastObject nextOrPreivious:YES count:3 step:1]];
        }
    }
}

-(void)ignoreModeLoadCell:(DWTableViewHelperCell *)cell indexPath:(NSIndexPath *)indexPath model:(DWTableViewHelperModel *)model {
    [self clearCell:cell indexPath:indexPath model:model];
    if (self.data2Load.count>0&&[self.data2Load indexOfObject:indexPath]==NSNotFound) {
        return;
    }
    if (self.isScrollingToTop) {
        return;
    }
    [self loadCell:cell model:model animated:NO];
}

-(void)loadCell:(__kindof DWTableViewHelperCell *)cell model:(DWTableViewHelperModel *)model animated:(BOOL)animated {
    ///此处处理占位图移除
    [cell hideLoadDataPlaceHolerAnimated:animated];
    if (model.cellHasBeenDrawn) {
        return;
    }
    cell.model = model;
    [model setValue:@YES forKey:@"cellHasBeenDrawn"];
}

-(void)commitSnapTransaction {
    [[DWTransaction transactionWithTarget:self selector:@selector(snapVisibleCell)] commit];
}

-(void)snapVisibleCell {
    [self snapVisibleCellWithCancelFlag:[self.flag restartAnCancelFlag]];
}

-(void)snapVisibleCellWithCancelFlag:(CancelFlag)flag {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * visibleCells = self.tabV.visibleCells;
        for (DWTableViewHelperCell * cell in visibleCells) {
            if (flag()) {
                return;
            }
            DWTableViewHelperModel * model = cell.model;
            UIImage * image = [self imageFromView:cell];
            model.cellSnap = image;
        }
    });
}

-(UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)clearCell:(__kindof DWTableViewHelperCell *)cell indexPath:(NSIndexPath *)indexPath model:(DWTableViewHelperModel *)model {
    
    UIImage * image;
    CGFloat height = [self tableView:self.tabV heightForRowAtIndexPath:indexPath];
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        image = model.cellSnap;
    }
    if (!image && DWDelegate && [DWDelegate respondsToSelector:@selector(dw_TableView:loadDataPlaceHolderForCell:forRowAtIndexPath:)]) {
        image = [DWDelegate dw_TableView:self.tabV loadDataPlaceHolderForCell:cell forRowAtIndexPath:indexPath];
    }
    if (!image) {
        image = self.loadDataPlaceHolder;
    }
    if (!image) {
        image = defaultImageWithHeight(height);
    }
    
    [cell showLoadDataPlaceHolder:image height:height];
    [model setValue:@NO forKey:@"cellHasBeenDrawn"];
}

-(NSInteger)distanceBetweenIndexPathA:(NSIndexPath *)idxPA indexPathB:(NSIndexPath *)idxPB {
    if ([idxPA isEqual:idxPB]) {
        return 0;
    }
    NSInteger distance = 0;
    NSInteger sectionDelta = idxPB.section - idxPA.section;
    if (sectionDelta > 0) {
        NSInteger row = idxPA.row + 1;
        NSInteger section = idxPA.section;
        while (section < idxPB.section) {
            distance += ([self.tabV numberOfRowsInSection:section]) - row;
            section ++;
            row = 0;
        }
        distance += (idxPB.row + 1);
    } else if (sectionDelta == 0) {
        distance = labs(idxPB.row - idxPA.row);
    } else {
        NSInteger row = idxPB.row + 1;
        NSInteger section = idxPB.section;
        while (section < idxPA.section) {
            distance += ([self.tabV numberOfRowsInSection:section]) - row;
            section ++;
            row = 0;
        }
        distance += (idxPA.row + 1);
    }
    return distance;
}

-(NSArray <NSIndexPath *>*)indexPathsAroundIndexPath:(NSIndexPath *)idxP nextOrPreivious:(BOOL)isNext count:(NSUInteger)count step:(NSInteger)step {
    
    if (count == 0) {
        return nil;
    }
    
    if (step < 1) {
        step = 1;
    }
    
    NSInteger section = idxP.section;
    NSInteger row = idxP.row;
    section = section < self.tabV.numberOfSections ? section :self.tabV.numberOfSections;
    row = row <= [self.tabV numberOfRowsInSection:section] ? row :[self.tabV numberOfRowsInSection:section];
    
    NSInteger fator = isNext ? 1 : -1;
    
    NSMutableArray * arr = [NSMutableArray array];
    do {
        row += step * fator;
        if (row >= 0 && row < [self.tabV numberOfRowsInSection:section]) {
            [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        } else {
        HandleSection:
            section += fator;
            if (section < 0 || section >= self.tabV.numberOfSections) {
                break;
            } else {
                if (row < 0) {
                    row += [self.tabV numberOfRowsInSection:section];
                    if (row < 0) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                } else {
                    row -= [self.tabV numberOfRowsInSection:section - 1];
                    if (row >= [self.tabV numberOfRowsInSection:section]) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                }
            }
        }
    } while (arr.count < count);
    
    return arr.copy;
}

-(void)lazyModeLoadCell:(DWTableViewHelperCell *)cell indexPath:(NSIndexPath *)indexPath model:(DWTableViewHelperModel *)model {
    [self clearCell:cell indexPath:indexPath model:model];
    if (!self.tabV.isDragging && !self.tabV.decelerating && !self.isScrollingToTop) {
        [self loadCell:cell model:model animated:YES];
    }
}

#pragma mark --- setter/getter ---
-(void)setDataSource:(NSArray<DWTableViewHelperModel *> *)dataSource
{
    _dataSource = dataSource;
    if (self.placeHolderView) {
        handlePlaceHolderView(self.placeHolderView,self.tabV, ![self caculateHaveData], &hasPlaceHolderView);
    }
}

-(void)setPlaceHolderView:(UIView *)placeHolderView
{
    if (_placeHolderView == placeHolderView) {
        return;
    }
    if (hasPlaceHolderView) {
        [_placeHolderView removeFromSuperview];
    }
    _placeHolderView = placeHolderView;
    if (_placeHolderView) {
        handlePlaceHolderView(_placeHolderView, self.tabV,![self caculateHaveData], &hasPlaceHolderView);
    }
}

-(void)setSelectEnable:(BOOL)selectEnable
{
    _selectEnable = selectEnable;
    if (!selectEnable) {
        self.lastSelected = nil;
    }
    [self.tabV setEditing:selectEnable animated:YES];
}

-(void)setMultiSelect:(BOOL)multiSelect
{
    _multiSelect = multiSelect;
    if (!multiSelect) {
        if (self.selectedRows.count > 1) {
            NSIndexPath * idxP = self.selectedRows.firstObject;
            [self.tabV reloadData];
            if (self.lastSelected) {
                [self.tabV selectRowAtIndexPath:self.lastSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                self.lastSelected = idxP;
                [self.tabV selectRowAtIndexPath:idxP animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

-(NSArray *)selectedRows
{
    return self.tabV.indexPathsForSelectedRows.copy;
}

-(NSMutableDictionary *)dic4CalCell
{
    if (!_dic4CalCell) {
        _dic4CalCell = [NSMutableDictionary dictionary];
    }
    return _dic4CalCell;
}

-(NSMutableArray *)data2Load
{
    if (!_data2Load) {
        _data2Load = [NSMutableArray array];
    }
    return _data2Load;
}

-(void)setLoadDataMode:(DWTableViewHelperLoadDataMode)loadDataMode {
    if (_loadDataMode != loadDataMode) {
        if (loadDataMode == DWTableViewHelperLoadDataLazyMode || loadDataMode == DWTableViewHelperLoadDataDefaultMode) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:DWTableViewHelperCellHitTestNotification object:nil];
        }
        if (loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ignoreModeReload) name:DWTableViewHelperCellHitTestNotification object:nil];
        }
        _loadDataMode = loadDataMode;
    }
}

#pragma mark --- override ---
-(void)dealloc {
    if (self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedMode || self.loadDataMode == DWTableViewHelperLoadDataIgnoreHighSpeedWithSnapMode) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark --- inline Method ---
static inline void handlePlaceHolderView(UIView * placeHolderView,UITableView * tabV,BOOL toSetHave,BOOL * hasPlaceHolderView){
    if (!toSetHave && *hasPlaceHolderView) {
        [placeHolderView removeFromSuperview];
        *hasPlaceHolderView = NO;
    }
    else if (toSetHave && !*hasPlaceHolderView)
    {
        [tabV addSubview:placeHolderView];
        *hasPlaceHolderView = YES;
    }
}


static inline UIImage * defaultImageWithHeight(CGFloat height) {
    if (height < 30) {
        return nil;
    } else if (height < 40) {
        return [[UIImage imageNamed:[NSString stringWithFormat:@"DWTableViewHelperResource.bundle/defaultLoadImage30"]] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 34) resizingMode:(UIImageResizingModeStretch)];
    } else if (height < 58) {
        return [[UIImage imageNamed:[NSString stringWithFormat:@"DWTableViewHelperResource.bundle/defaultLoadImage40"]] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 50, 10,150) resizingMode:(UIImageResizingModeStretch)];
    } else if (height < 102) {
        return [[UIImage imageNamed:[NSString stringWithFormat:@"DWTableViewHelperResource.bundle/defaultLoadImage58"]] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 60, 28, 180) resizingMode:UIImageResizingModeStretch];
    } else if (height < 145) {
        return [[UIImage imageNamed:[NSString stringWithFormat:@"DWTableViewHelperResource.bundle/defaultLoadImage102"]] resizableImageWithCapInsets:UIEdgeInsetsMake(70, 125, 28, 220) resizingMode:(UIImageResizingModeStretch)];
    } else {
        return [[UIImage imageNamed:[NSString stringWithFormat:@"DWTableViewHelperResource.bundle/defaultLoadImage145"]] resizableImageWithCapInsets:UIEdgeInsetsMake(100, 150, 40, 240) resizingMode:(UIImageResizingModeStretch)];
    }
}

static inline NSArray * DWParas(NSObject * aObj,...){
    NSMutableArray* keys = [NSMutableArray array];
    va_list argList;
    if(aObj){
        [keys addObject:aObj];
        va_start(argList, aObj);
        id arg;
        while ((arg = va_arg(argList, id))) {
            [keys addObject:arg];
        }
    }
    va_end(argList);
    return keys.copy;
};

static inline NSMutableArray * filterArray(NSArray * array,BOOL(^block)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))
{
    NSMutableArray * arr = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj,idx,arr.count,stop)) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

static inline DWTableViewHelperModel * PlaceHolderCellModelAvoidCrashingGetter () {
    if (PlaceHolderCellModelAvoidCrashing == nil) {
        PlaceHolderCellModelAvoidCrashing = [DWTableViewHelperModel new];
        PlaceHolderCellModelAvoidCrashing.cellRowHeight = 0;
        PlaceHolderCellModelAvoidCrashing.cellClassStr = NSStringFromClass([DWTableViewHelperCell class]);
        PlaceHolderCellModelAvoidCrashing.cellID = @"PlaceHolderCellAvoidCrashing";
    }
    return PlaceHolderCellModelAvoidCrashing;
}

@end


@interface DWTableViewHelperModel ()

///计算的竖屏行高
@property (nonatomic ,assign) CGFloat calRowHeightV;

///计算的横屏行高
@property (nonatomic ,assign) CGFloat calRowHeightH;

///原始cell选择样式
@property (nonatomic ,assign) NSInteger originalSelectionStyle;

///默认cell类
@property (nonatomic ,copy) NSString * defaultCellClassStr;

///默认cellID
@property (nonatomic ,copy) NSString * defaultCellID;

@end

@implementation DWTableViewHelperModel

@synthesize cellRowHeight,cellEditSelectedIcon,cellEditUnselectedIcon;
@synthesize cellClassStr = _cellClassStr;
@synthesize cellID = _cellID;

-(instancetype)init{
    if (self = [super init]) {
        self.cellRowHeight = -1;
        if (!ImageNull) {
            ImageNull = [UIImage new];
        }
        self.originalSelectionStyle = -1;
        NSString * cellClass = NSStringFromClass([self class]);
        NSArray * arr = [cellClass componentsSeparatedByString:@"Model"];
        if (arr.count) {
            cellClass = [NSString stringWithFormat:@"%@Cell",arr.firstObject];
        } else {
            cellClass = @"DWTableViewHelperCell";
        }
        self.cellClassStr = cellClass;
        self.cellID = [NSString stringWithFormat:@"%@DefaultCellID",cellClass];
        self.cellEditSelectedIcon = ImageNull;
        self.cellEditUnselectedIcon = ImageNull;
        self.calRowHeightH = -1;
        self.calRowHeightV = -1;
    }
    return self;
}

-(void)setNeedsReAutoCalculateRowHeight {
    self.calRowHeightH = -1;
    self.calRowHeightV = -1;
}

#pragma mark --- setter/getter ---
-(NSString *)cellClassStr {
    if (!_cellClassStr) {
        return self.defaultCellClassStr;
    }
    return _cellClassStr;
}

-(void)setCellClassStr:(NSString *)cellClassStr {
    if (![_cellClassStr isEqualToString:cellClassStr]) {
        _cellClassStr = cellClassStr;
        if (!_cellID) {
            _defaultCellID = [NSString stringWithFormat:@"%@DefaultCellID",cellClassStr];
        }
    }
}

-(NSString *)cellID {
    if (!_cellID) {
        return self.defaultCellID;
    }
    return _cellID;
}

-(CGFloat)autoCalRowHeight {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown) {
        return self.calRowHeightV;
    } else {
        return self.calRowHeightH;
    }
}

-(void)setAutoCalRowHeight:(CGFloat)autoCalRowHeight {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown) {
        self.calRowHeightV = autoCalRowHeight;
    } else {
        self.calRowHeightH = autoCalRowHeight;
    }
}


-(NSString *)defaultCellClassStr {
    if (!_defaultCellClassStr) {
        NSString * cellClass = NSStringFromClass([self class]);
        NSArray * arr = [cellClass componentsSeparatedByString:@"Model"];
        if (arr.count) {
            cellClass = [NSString stringWithFormat:@"%@Cell",arr.firstObject];
        } else {
            cellClass = @"DWTableViewHelperCell";
        }
        _defaultCellClassStr = cellClass;
    }
    return _defaultCellClassStr;
}

-(NSString *)defaultCellID {
    if (!_defaultCellID) {
        _defaultCellID = [NSString stringWithFormat:@"%@DefaultCellID",self.defaultCellClassStr];
    }
    return _defaultCellID;
}

@end


NSNotificationName const DWTableViewHelperCellHitTestNotification = @"DWTableViewHelperCellHitTestNotification";

@interface DWTableViewHelperCell ()

@property (nonatomic ,strong) UIImageView * loadDataImageView;

@end

@implementation DWTableViewHelperCell
static UIImage * defaultSelectIcon = nil;
static UIImage * defaultUnselectIcon = nil;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
    [self setupConstraints];
}

-(void)layoutSubviews
{
    BOOL toSetSelectIcon = self.model.cellEditSelectedIcon != ImageNull && self.model.cellEditSelectedIcon != nil;
    BOOL toSetUnselectIcon = self.model.cellEditUnselectedIcon != ImageNull && self.model.cellEditUnselectedIcon != nil;
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img = (UIImageView *)v;
                    if (self.selected) {
                        if (toSetSelectIcon) {
                            if (!defaultSelectIcon) {
                                defaultSelectIcon = img.image;
                            }
                            img.image = self.model.cellEditSelectedIcon;
                        } else if (defaultSelectIcon) {
                            img.image = defaultSelectIcon;
                        }
                    } else {
                        if (toSetUnselectIcon) {
                            if (!defaultUnselectIcon) {
                                defaultUnselectIcon = img.image;
                            }
                            img.image = self.model.cellEditUnselectedIcon;
                        } else if (defaultUnselectIcon) {
                            img.image = defaultUnselectIcon;
                        }
                    }
                }
            }
        }
    }
    [super layoutSubviews];
}

///适配第一次图片为空的情况
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing && self.selectionStyle != UITableViewCellSelectionStyleDefault) {//编辑状态下保证非无选择样式
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (!editing && self.selectionStyle != self.model.originalSelectionStyle) {//退出编辑状态是恢复原始选择样式
        self.selectionStyle = self.model.originalSelectionStyle;
    }
    BOOL toSetUnselectIcon = self.model.cellEditUnselectedIcon != ImageNull && self.model.cellEditUnselectedIcon != nil;
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img=(UIImageView *)v;
                    if (!self.selected) {
                        if (toSetUnselectIcon) {
                            if (!defaultUnselectIcon) {
                                defaultUnselectIcon = img.image;
                            }
                            img.image = self.model.cellEditUnselectedIcon;
                        } else if (defaultUnselectIcon) {
                            img.image = defaultUnselectIcon;
                        }
                    }
                }
            }
        }
    }
}

-(void)setupUI {
    ///去除选择背景
    self.backgroundColor = [UIColor whiteColor];
    self.multipleSelectionBackgroundView = [UIView new];
    self.selectedBackgroundView = [UIView new];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.loadDataImageView = [UIImageView new];
    self.loadDataImageView.backgroundColor = [UIColor whiteColor];
}

-(void)setupConstraints {
    
}

-(void)setModel:(__kindof DWTableViewHelperModel *)model
{
    _model = model;
    if (model.originalSelectionStyle == -1) {//仅在初次生成cell的时候同步cell的选择样式
        model.originalSelectionStyle = self.selectionStyle;
    }
}

-(void)showLoadDataPlaceHolder:(UIImage *)image height:(CGFloat)height{
    CGRect bounds = self.bounds;
    bounds.size.height = height;
    self.loadDataImageView.frame = bounds;
    [self.contentView addSubview:self.loadDataImageView];///为了保证始终在顶层
    self.loadDataImageView.image = image;
    self.loadDataImageView.alpha = 1;
}

-(void)hideLoadDataPlaceHolerAnimated:(BOOL)animated {
    [UIView beginAnimations:@"hideAni" context:nil];
    [UIView setAnimationDuration:animated?0.4:0];
    self.loadDataImageView.alpha = 0;
    [UIView commitAnimations];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:DWTableViewHelperCellHitTestNotification object:nil];
    return [super hitTest:point withEvent:event];
}

@end

