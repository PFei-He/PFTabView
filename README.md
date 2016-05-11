[PFTabView](https://github.com/PFei-He/PFTabView)
===
 
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://raw.githubusercontent.com/PFei-He/PFTabView/master/LICENSE)
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/PFTabView.svg)](https://img.shields.io/cocoapods/v/PFTabView.svg)
 
可滑动的标签

版本
---
0.4.0

说明
---
#### 关于项目
PFTabView是一款简单接入便可实现新闻客户端顶部滑动标签的开源库。

#### 关于CocoaPods
---
```
target 'YourTarget' do
    platform:ios, '7.0'
    pod 'PFTabView', '~> 0.4'
end
```

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
