#
# Be sure to run `pod lib lint MGKalman.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MGKalman"
  s.version          = "0.1.0"
  s.summary          = "An efficient and simple implementation of the Kalman filter in Objective C"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "MGKalman is an efficient and simple implementation of the Kalman filter in Objective C."

  s.homepage         = "https://github.com/ghenania/MGKalman"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mohamed GHENANIA" => "mohamed.ghenania@intersection-lab.com" }
  s.source           = { :git => "https://github.com/ghenania/MGKalman.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MGKalman' => ['Pod/Assets/*.png']
  }

  #s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Accelerate'
  s.dependency  'MGMatrix', '~> 0.2.0'
end
