# Podfile
def commonPods
    pod 'DateToolsSwift', '~> 2.0.3'
    pod 'Swinject', '~> 2.2.0'
    pod 'RealmSwift', '~> 3.1.1'
    pod 'SwiftLint', '~> 0.25.0'
    pod 'SwipeCellKit', '~> 2.0.1'
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
        pod 'Hero', '~> 1.1.0'
        pod 'NVActivityIndicatorView', '~> 4.1.1'
        pod 'UIColor_Hex_Swift', '~> 3.0.2'
        pod 'DZNEmptyDataSet', '~> 1.8.1'
        pod 'Eureka', '~> 4.0.0'
        pod 'JTAppleCalendar', '~> 7.1.5'
        pod 'Dwifft'
    end

end



