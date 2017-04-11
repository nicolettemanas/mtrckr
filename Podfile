# Podfile

use_frameworks!

def commonPods
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'DateToolsSwift', '~> 2.0.3'
#    pod 'SugarRecord/CoreData', '~> 3.0.0'
    pod 'Swinject', '~> 2.0.0'
#    pod 'ObjectMapper', '~> 2.2.5'
    pod 'RealmSwift', '~> 2.5.1'
    pod 'SwiftLint', '~> 0.18.1'

#    pod 'SwinjectStoryboard', '~> 1.0.0'
end

target "mtrckr" do
    pod 'Alamofire', '~> 4.4.0'
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
