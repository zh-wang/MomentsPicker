#
# Be sure to run `pod lib lint MomentsPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MomentsPicker"
  s.version          = "1.0.0"
  s.summary          = "iOS Moments-like image picking library"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
iOS Moments-like image picking library with multiple selection support.
                       DESC

  s.homepage         = "https://github.com/zh-wang/MomentsPicker"
  s.screenshots      = "http://i.imgur.com/jskUS9P.png"
  s.license          = 'MIT'
  s.author           = { "zh-wang" => "viennakanon@gmail.com" }
  s.source           = { :git => "https://github.com/zh-wang/MomentsPicker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/viennakanon'

  s.platform     = :ios, '8.3'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MomentsPicker' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Photos'
  # s.dependency 'AFNetworking', '~> 2.3'
end
