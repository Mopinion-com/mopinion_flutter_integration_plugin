#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mopinion_flutter_integration_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mopinion_flutter_integration_plugin'
  s.version          = '3.0.7'
  s.summary          = 'A Flutter plugin to integrate Mopinion native mobile feedback forms SDKs.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'mopinion_flutter_integration_plugin/Sources/mopinion_flutter_integration_plugin/**/*'
  s.dependency 'Flutter'
  s.dependency 'MopinionSDK', '~> 1.3.1'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
