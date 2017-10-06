# Podfile

use_frameworks!

def commonPods
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', '~> 2.1.0'
    pod 'RealmSwift', '~> 2.8.3'
    pod 'SwiftLint', '~> 0.18.1'
end

target "mtrckr" do
#    pod 'CryptoSwift', '~> 0.6.9'
    pod 'Hero', '~> 0.3.6'
    pod 'NVActivityIndicatorView', '~> 3.6.1'
    pod 'UIColor_Hex_Swift', '~> 3.0.2'
    pod 'SwipeCellKit', '~> 1.9.1'
    pod 'DZNEmptyDataSet'
#    pod 'Charts', '~> 3.0.2'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'feature/Xcode9-Swift3_2'
    pod 'JTAppleCalendar'
    pod 'Dwifft'

    commonPods
 
 abstract_target 'Tests' do
    inherit! :search_paths
    target "mtrckrTests"

    pod 'Mockingjay', '~> 2.0.0'
    pod 'Quick', '~> 1.1.0'
    pod 'Nimble', '~> 7.0.1'
    commonPods
  end
end
