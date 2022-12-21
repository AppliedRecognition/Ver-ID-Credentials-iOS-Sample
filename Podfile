platform :ios, '14.0'

target 'ID Capture' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ID Capture
  pod 'Ver-ID', '>= 2.7.2', '< 3.0.0'
  pod 'Ver-ID-Serialization', '~> 1.1'

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'BUILD_LIBRARY_FOR_DISTRIBUTION'
      end
    end
  end
end
