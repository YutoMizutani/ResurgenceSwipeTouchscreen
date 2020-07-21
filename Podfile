# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'ResurgenceSwipeTouchscreen' do
 pod 'SwiftyDropbox'
 pod 'Eureka'
 pod 'RealmSwift'
 pod 'RxCocoa'
 pod 'RxGesture'
 pod 'RxSwift'
 pod 'OperantKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "4.2"
        end
    end
end