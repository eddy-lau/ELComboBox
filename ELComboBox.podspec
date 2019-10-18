#
# Be sure to run `pod lib lint ELComboBox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ELComboBox"
  s.version          = "1.3.0"
  s.summary          = "Combo box for iOS."
  s.description      = <<-DESC
                       Combo box with auto-complete for iOS.
                       DESC
                       

  s.homepage         = "https://github.com/eddy-lau/ELComboBox"
  s.license          = 'MIT'
  s.author           = { "Eddie Lau" => "eddie@touchutility.com" }
  s.source           = { :git => "https://github.com/eddy-lau/ELComboBox.git", :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.requires_arc = false

  s.source_files = 'ELComboBox/Classes/**/*'
end
