#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint trainingkit_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'trainingkit_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter bridge for FizzUp TrainingKit.'
  s.description      = <<-DESC
Flutter bridge for FizzUp TrainingKit. Launch classic and video workouts from a GraphQL session payload.
                       DESC
  s.homepage         = 'https://github.com/getfizzup/trainingkit-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fysiki' => 'support@fizzup.com' }
  s.source           = { :git => 'https://github.com/getfizzup/trainingkit-flutter.git', :tag => s.version.to_s }
  s.source_files     = 'Classes/**/*'

  # The TrainingKit XCFramework is not versioned in this repository. It is
  # fetched from the stable `main` branch of getfizzup/trainingkit-ios-sdk
  # during `pod install` and vendored from ios/Vendor.
  s.prepare_command     = './scripts/fetch-ios-trainingkit.sh'
  s.vendored_frameworks = 'Vendor/TrainingKit.xcframework'

  s.dependency 'Flutter'
  s.platform = :ios, '15.1'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
