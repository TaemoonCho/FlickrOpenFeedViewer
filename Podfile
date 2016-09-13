# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

post_install do | installer |
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
    project_path = installer.analysis_result.target_inspections.first[1].project_path
    add_check_lint_script_if_need(project_path.to_s)
end

def check_lint_script(target)
    target.shell_script_build_phases.each do |script|
        if script.name == "[SwiftLint] Check swiftlint"
            return true
        end
    end
    return false
end

def add_check_lint_script_if_need(project_path)
    project = Xcodeproj::Project.open(project_path)
    main_target = project.targets.first
    unless check_lint_script(main_target)
        phase = main_target.new_shell_script_build_phase("[SwiftLint] Check swiftlint")
        phase.shell_script = "\
if which swiftlint >\/dev\/null; then \n\
  swiftlint \n\
else \n\
  echo \"warning: SwiftLint not installed, download from https:\/\/github.com\/realm\/SwiftLint\" \n\
fi"
        project.save()
    end
end

use_frameworks!

def testing_pods
    pod 'Quick', :git => 'https://github.com/Quick/Quick', :tag => 'v0.9.0'
    pod 'Nimble', :git => 'https://github.com/TaemoonCho/Nimble.git', :tag => 'v3.2.1'

    pod 'RxBlocking', '~> 2.6'
    pod 'RxTests',    '~> 2.6'
end

def ui_pods
    pod 'ActionSheetPicker-3.0', '~> 2.2.0'
    pod 'SwiftLoader'
end

def base_pods
    pod 'SwiftyJSON'
    pod 'SwiftDate'
    pod 'Alamofire', '~> 3.5'
    pod 'RxSwift',    '~> 2.6'
    pod 'RxCocoa',    '~> 2.6'
    pod 'RxAlamofire', '~> 2.5'
end

target 'FlickrOpenFeedViewer' do
    ui_pods
    base_pods
end

target 'FlickrOpenFeedViewerTests' do
    base_pods
    testing_pods
end

#target 'FlickrSlideAlbumUITests' do
#	ui_pods
#	base_pods
#	testing_pods
#end

