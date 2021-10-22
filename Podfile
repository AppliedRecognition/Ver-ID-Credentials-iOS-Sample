workspace 'ID Capture.xcworkspace'
project 'ID Capture.xcodeproj'

platform :ios, '11.0'

target 'ID Capture' do
  use_frameworks!
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end

  # Pods for ID Capture
  pod 'Ver-ID', '>= 2.3.2', '< 3.0'
  pod 'RxCocoa', '~> 5.0'
  pod 'RxSwift', '~> 5.0'
  pod 'ID-Card-Camera', '>= 1.4.1', '< 2.0'
  pod 'PPBlinkID', '5.14'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end
