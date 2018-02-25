# Podfile
def commonPods
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', '~> 2.1.0'
    pod 'RealmSwift', '~> 3.1.1'
    pod 'SwiftLint', '~> 0.18.1'
    pod 'SwipeCellKit', '~> 1.9.1'
end

abstract_target 'Tests' do
    use_frameworks!
    commonPods
    
    target "mtrckrTests" do
        pod 'Mockingjay', '~> 2.0.0'
        pod 'Quick', '~> 1.1.0'
        pod 'Nimble', '~> 7.0.1'
    end
    
    target "mtrckr" do
        #    pod 'CryptoSwift', '~> 0.6.9'
        pod 'Hero', '~> 0.3.6'
        pod 'NVActivityIndicatorView', '~> 3.6.1'
        pod 'UIColor_Hex_Swift', '~> 3.0.2'
        pod 'DZNEmptyDataSet'
        pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'feature/Xcode9-Swift3_2'
        pod 'JTAppleCalendar'
        pod 'Dwifft'
    end

end



