platform :ios, ‘8.0’

target 'iSistemium' do
    pod 'KiteJSONValidator', '~> 0.2.3'
    pod 'Reachability', '~> 3.2’
    pod 'ScanAPI', :path => '../ScanApiSDK'
    pod 'JNKeychain', '~> 0.1.4'
    pod 'Socket.IO-Client-Swift', '~> 8.0.2'
    use_frameworks! 
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
