# Podfile

use_frameworks!

def commonPods
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', :git => 'https://github.com/Swinject/Swinject.git', :branch => 'swift4'
    pod 'RealmSwift', '~> 2.8.3'
    pod 'SwiftLint', '~> 0.18.1'
end

target "mtrckr" do
    pod 'CryptoSwift', :git => 'https://github.com/krzyzanowskim/CryptoSwift.git', :branch => 'develop'
    pod 'Hero', '~> 0.3.6'
    pod 'NVActivityIndicatorView', '~> 3.6.1'
    commonPods
 
 abstract_target 'Tests' do
    inherit! :search_paths
    target "mtrckrTests"

    pod 'Mockingjay', '~> 2.0.0'
    pod 'Quick', '1.0.0'
    pod 'Nimble', '5.0.0'
    commonPods
  end
end
