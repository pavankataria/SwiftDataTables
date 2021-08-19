#
# Be sure to run `pod lib lint SwiftDataTables.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftDataTables'
  s.version          = '0.8.3'
  s.summary          = 'A Swift Data Table package that allows ordering, searching, and paging with extensible options.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "SwiftDataTables allows you to display grid-like data sets in a nicely formatted table for iOS. The main goal for the end-user are to be able to obtain useful information from the table as quickly as possible with the following features: ordering, searching, and paging; where as for the developer is to allow for easy implementation with extensible options. This package was inspired by Javascript's DataTables package."


  s.homepage         = 'https://github.com/pavankataria/SwiftDataTables'
  # s.screenshots     = 'https://github.com/pavankataria/SwiftDataTables/raw/master/Example/SwiftDataTables-Preview.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pavankataria' => 'info@pavankataria.com' }
  s.source           = { :git => 'https://github.com/pavankataria/SwiftDataTables.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/pavan_kataria'

  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.source_files = 'SwiftDataTables/**/*.swift'
  s.resources    = 'SwiftDataTables/SwiftDataTables.bundle'

end
