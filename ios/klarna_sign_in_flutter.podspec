Pod::Spec.new do |s|
  s.name             = 'klarna_sign_in_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin bridging Klarna Sign-in (iOS/Android)'
  s.description      = <<-DESC
A Flutter plugin for Sign in with Klarna, supporting iOS and Android.
  DESC
  s.homepage         = 'https://your.repo.url'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'You' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.requires_arc = true
  s.platform     = :ios, '13.0'
  s.dependency 'Flutter'        # 必须加
  s.dependency 'KlarnaMobileSDK'
  s.frameworks = 'AuthenticationServices', 'UIKit'
end