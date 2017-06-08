# Podfile

use_frameworks!

def commonPods
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', '~> 2.0.0'
    pod 'RealmSwift', '~> 2.7.0'
    pod 'SwiftLint', '~> 0.18.1'
end

target "mtrckr" do
    pod 'CryptoSwift', '~> 0.6.9'
    pod 'Hero', '~> 0.3.6'
    pod 'SkyFloatingLabelTextField', '~> 3.1.0'
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
