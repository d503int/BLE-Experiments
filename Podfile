install! 'cocoapods', :deterministic_uuids => false

source 'https://github.com/CocoaPods/Specs.git'

workspace 'BLE-Experiments'
project 'BLE-Experiments/BLE-Experiments.xcodeproj'
project 'BLE-Peripheral/BLE-Peripheral.xcodeproj'
project 'BLE-Central-OSX/BLE-Central-OSX.xcodeproj'

use_frameworks!
inhibit_all_warnings!

def shared_pods
    pod 'XCGLogger', '~> 3.2'
    
    pod 'Operations', '~> 3.4.0'
    pod 'ReactiveCocoa', '~> 4.2.2'
end

target 'BLE-Experiments' do
    platform :ios, '8.0'

    project 'BLE-Experiments/BLE-Experiments.xcodeproj'
    
    pod 'FLEX', '~> 2.3.0'
    
    shared_pods
end

target 'BLE-Peripheral' do
    platform :ios, '8.0'

    project 'BLE-Peripheral/BLE-Peripheral.xcodeproj'
    
    pod 'FLEX', '~> 2.3.0'
    
    shared_pods
    
    target 'BLE-PeripheralTests' do
        inherit! :search_paths
    end
end


target 'BLE-Central-OSX' do
    platform :osx, '10.10'
    
    project 'BLE-Central-OSX/BLE-Central-OSX.xcodeproj'
    
    shared_pods
    
    
    target 'BLE-Central-OSXTests' do
        inherit! :search_paths
    end
end
