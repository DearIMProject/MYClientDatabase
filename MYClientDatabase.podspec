
Pod::Spec.new do |s|
  s.name             = 'MYClientDatabase'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MYClientDatabase.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/mingyan/MYClientDatabase'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wenmy' => 'wenmy@tuya.com' }
  s.source           = { :git => 'https://github.com/mingyanwen/MYClientDatabase.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  s.source_files = 'MYClientDatabase/Classes/**/*'
  s.public_header_files = 'MYClientDatabase/Classes/public/**/*.h'
  s.resource_bundles = {
    'MYClientDatabase' => ['MYClientDatabase/Assets/**/*.sqlite']
  }
  
  s.subspec 'Debug' do |subspec|
    subspec.source_files = 'MYClientDatabase/Debug/**/*'  # 模块的源代码文件
    
    # 模块的依赖关系
    subspec.dependency 'MYDearDebug'

    
#     # 模块的其他设置
#     module.frameworks = 'UIKit', 'Foundation'
#     module.weak_frameworks = 'SomeFramework'
#     module.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-D MODULE_NAME_ENABLED' }
  end
   
   
   s.dependency 'FMDB'
end
