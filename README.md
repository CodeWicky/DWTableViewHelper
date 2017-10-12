<p align="center" >
<img src="https://github.com/CodeWicky/DWTableViewHelper/raw/master/%E5%8A%A8%E7%94%BB%E5%B1%95%E7%A4%BA.gif" alt="DWTableViewHelper" title="DWTableViewHelper">
</p>

## Description
This is a Class help you to build a tableView Quickly.

All of the tableView cells are driven by the Model.

By this way you may needn't care about the original Delegate of tableView.Use the model to control the cell.

So your code of tableView in VC may be slim~

Besides that,I also consider that sometime you may need implementation some delegate yourself to customsize the performance of the tableView so I provide the Delegate Map of all original Delegate that tableView may include.

And I also provide some basic quick API for usual Operation of the tableView so something you need may just a property of the Helper.

All I have done is to bulid a tableView easier and I'm improving it step by step.

## 描述
这是一个可以帮你快速创建列表视图的工具类。

所有的cell都是以数据模型驱动的。

这样的话，你将不在关心TableView原始的代理，只要使用模型去控制cell即可。

所以你控制器中tableView的代码将会得到瘦身~

此外，考虑到有时为了定制一些TableView的行为，你可能需要自己实现TableView的一些代理，所以我同样提供了TableView可能包括的所有代理的映射。

并且我还提供了一些快捷的常用API，这样的话，也许你只需要开启一个属性即可做到你想要做的很多事。

我所做的一切都是为了更加便捷的布置一个列表视图，我在一点点的改进这个工具类。

## Function

- Slim your ViewController.

- Provide all default implementation Delegate/DataSource/Prefetch method.If you have nothing to customsize,you need implement none of them.

- Provide cellShowAnimation Delegate.Just use it to customsize show animation for each cell.

- Auto handle the no data PlaceHolderView.If the dataSource of Helper is empty,it will show the NO DATA VIEW.

- Handle the Selection operation easier.

- Auto calculate the rowHeight and cache it.

## 功能

- 解耦。

- 为UITableView的delegate/dataSource/prefetch中所有代理提供默认实现，如果没有特殊定制要求，所有代理你都不需要自行实现。

- 补充cell出现动画，你可以使用它来定制每一个cell的展现动画。

- 自动处理占位图。当你的数据源为空时自动展示无数据的占位图。

- 简化TableView列表的选择及多选操作。

- 非固定行高cell会自动计算行高并缓存行高。

## Usage
Firstly,drag it into your project or use cocoapods.

	pod 'DWTableViewHelper'


To use the DWTableViewHelper,you need to Follow these:

- Your cell must be a subclass of DWTableViewHelperCell.

- Your model must be a subclass of DWTableVeiwHelperModel.

And you also need to initialized the Helper along with the tableView.eg.:


    -(UITableView *)tabV {
        if (!_tabV) {
            _tabV = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)
            ];
            self.helper = [[DWTableViewHelper alloc] initWithTabV:_tabV dataSource:self.dataArr];
        }
        return _tabV;
    }

I have done lots to Prevent Crash On ReleaseMode but this is not the reason for your not Set the property On propose.

So you'd better to set the cellClassStr、cellID at least once in Helper or Model.

And use the MultiSection Mode correctly.

Some other usage you may try it yourself.

My note covers every detail.

## 如何使用
首先，你应该将所需文件拖入工程中，或者你也可以用Cocoapods去集成他。

	pod 'DWTableViewHelper'

当使用DWTableViewHelper的时候，你应该遵从以下几点：

- 你使用的cell应该是DWTableViewHelperCell的子类。

- 你使用的数据模型应该是DWTableViewHelperModel的子类

并且记得在你初始化的时候同时初始化Helper类。例如：

    -(UITableView *)tabV {
        if (!_tabV) {
            _tabV = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)
            ];
            self.helper = [[DWTableViewHelper alloc] initWithTabV:_tabV dataSource:self.dataArr];
        }
        return _tabV;
    }

我做了很多容做措施来保证发布模式下不会崩溃，但这并不是你故意写错的理由。

所以你最好在Helper或者Model中至少一次设置cellClassStr、cellID。

同时正确的使用MultiSection属性，来区分二维数组还是一维数组。

一些其他的使用方法相信看到属性名你就会明白，你也可以自己尝试着使用一下。

我的注释还是很全的=。=


## Contact With Me

You may issue me on [my Github](https://github.com/CodeWicky/DWTableViewHelper) or send me a email at [codeWicky@163.com]() to tell me some advices or the bug,I will be so appreciated.

If you like it please give a star.

## 联系作者
你可以通过在[我的Github](https://github.com/CodeWicky/DWTableViewHelper)上给我留言或者给我发送电子邮件[codeWicky@163.com]()来给我提一些建议或者指出我的bug,我将不胜感激。

如果你喜欢这个小东西，记得给我一个star吧，么么哒~

