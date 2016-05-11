Pod::Spec.new do |s|
    s.name         = "PFTabView"
    s.version      = "0.4.0"
    s.summary      = "PFTabView是一款简单接入便可实现新闻客户端顶部滑动标签的开源库。"
    s.homepage     = "https://github.com/PFei-He/PFTabView"
    s.license      = "MIT"
    s.author       = { "PFei-He" => "498130877@qq.com" }
    s.platform     = :ios, "7.0"
    s.ios.deployment_target = "7.0"
    s.source       = { :git => "https://github.com/PFei-He/PFTabView.git", :tag => s.version }
    s.source_files  = "PFTabView/*"
    s.frameworks = "Foundation", "CoreGraphics", "UIKit"
    s.requires_arc = true
end
