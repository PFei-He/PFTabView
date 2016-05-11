[PFTabView](https://github.com/PFei-He/PFTabView)
===
可滑动的标签

版本
---
0.4.0

说明
---
#### 关于项目
PFTabView是一款简单接入便可实现新闻客户端顶部滑动标签的开源库。

#### 关于CocoaPods
本项目并未使用CocoaPods进行版本管理，后续会考虑加入。

示例代码
---
```objective-c
@weakify_self
[self.tabView numberOfItemUsingBlock:^NSInteger{
    return 4;
}];
```

```objective-c
[self.tabView sizeOfItemUsingBlock:^CGSize{
    @strongify_self
    return CGSizeMake(self.view.bounds.size.width/4, 40);
}];
```

```objective-c
[self.tabView viewForItemUsingBlock:^UIView *(NSInteger index) {
    @strongify_self
    return self.views[index];
}];
```

运行效果展示
--------------
![image](https://github.com/PFei-He/PFTabView/blob/master/PFTabView.gif)

许可证
---
`PFTabView`使用 MIT 许可证，详情见 [LICENSE](https://raw.githubusercontent.com/PFei-He/PFTabView/master/LICENSE) 文件。
