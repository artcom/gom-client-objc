Pod::Spec.new do |s|
  
  s.name         = "gom-client-objc"
  s.version      = "0.0.1"
  s.summary      = "A GOM client written in Objective-C for the Cocoa framework."
  
  s.description  = <<-DESC
                    This project contains a GOM client written in Objective-C for the Cocoa framework. This client can be used in iOS and OS X projects.
                   DESC
  s.homepage     = "https://github.com/artcom/gom-client-objc"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Julian Krumow" => "julian.krumow@artcom.de" }
  
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  
  s.source       = { :git => "git://gitorious.staging.t-gallery/core/gom-client-objc.git", :commit => '5596a38a451e5d3b4329680c7367164f475d0f67' }
  s.source_files  = 'gom-client-objc/gom-client/**/*.{h,m}'
  
  s.requires_arc = true
  s.dependency 'SocketRocket', '~> 0.3'

end
