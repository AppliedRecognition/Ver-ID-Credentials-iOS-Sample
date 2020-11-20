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
  pod 'Ver-ID-UI', '2.0.0-beta.04'
  pod 'RxCocoa', '~> 5.0'
  pod 'RxSwift', '~> 5.0'
  pod 'ID-Card-Camera', '>= 1.4.1', '< 2.0'
  pod 'PPBlinkID', '~> 5.8'
  pod 'AAMVA-Barcode-Parser', '1.4.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end
