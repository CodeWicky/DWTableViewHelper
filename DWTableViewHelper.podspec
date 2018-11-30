Pod::Spec.new do |s|
  s.name         = 'DWTableViewHelper'
  s.version      = '1.1.7.2'
  s.summary      = 'DWTableViewHelper is a tool object to slim your ViewController and let you build a tableView easily.'
  s.description  = "DWTableViewHelper is a tool object to slim your ViewController and let you build a tableView easily.DWTableViewHelper能够瘦身你的控制器，达>到解耦效果，并且提供一些便捷的TableView开发接口。"
  s.homepage     = "https://github.com/CodeWicky/DWTableViewHelper"
  s.social_media_url   = "http://www.jianshu.com/u/a56ec10f6603"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "codeWicky" => "codewicky@163.com" }
  s.source       = { :git => "https://github.com/CodeWicky/DWTableViewHelper.git", :tag => s.version.to_s }
  s.source_files = "DWTableViewHelper/**/*.{h,m}"
  s.resource = 'DWTableViewHelper/DWTableViewHelperResource.bundle'
  s.ios.deployment_target = '7.0'
  s.frameworks   = 'UIKit'
  s.requires_arc = true
end

