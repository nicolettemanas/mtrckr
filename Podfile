# Podfile

use_frameworks!

def commonPods
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', '~> 2.0.0'
    pod 'RealmSwift', '~> 2.7.0'
    pod 'SwiftLint', '~> 0.18.1'
    pod 'CryptoSwift', '~> 0.6.9'
end

target "mtrckr" do
#    pod 'Alamofire', '~> 4.4.0'
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
