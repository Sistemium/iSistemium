platform :ios, '7.0'
pod 'KiteJSONValidator', :git => 'https://github.com/grgcombs/KiteJSONValidator.git', :tag => 'v0.1.2-Pod'
pod 'AWSiOSSDKv2', '~> 2.2'
pod 'Reachability', '~> 3.1.0'
pod 'SocketRocket', '~> 0.4.1'

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
