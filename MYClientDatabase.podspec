
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

  s.ios.deployment_target = '10.0'

  s.source_files = 'MYClientDatabase/Classes/**/*'
  s.public_header_files = 'MYClientDatabase/Classes/**/*.h'
  s.resource_bundles = {
    'MYClientDatabase' => ['MYClientDatabase/Assets/**/*.sqlite']
  }
   
   s.dependency 'FMDB'
end
