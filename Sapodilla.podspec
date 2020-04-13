Pod::Spec.new do |s|  
  s.name             = "Sapodilla"  
  s.version          = "0.0.1"  
  s.summary          = "A  http network with swift."  
  s.description      = <<-DESC              
	  	        It is a http network with swift.
			DESC  
  s.homepage         = "https://github.com/AliliWVIP/Sapodilla"  
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"  
  s.license          = 'Apache-2.0'  
  s.author           = { "AliliWl" => "aliliwvip@gmail.com" }  
  s.source           = { :git => "https://github.com/AliliWVIP/Sapodilla.git", :tag => s.version.to_s }  
  # s.social_media_url = 'https://twitter.com/NAME'  
  
  s.platform     = :ios, '4.3'  
  # s.ios.deployment_target = '5.0'  
  # s.osx.deployment_target = '10.7'  
  s.requires_arc = true  
  
  s.source_files = 'Sapodilla/*'  
  # s.resources = 'Assets'  
  
  # s.ios.exclude_files = 'Classes/osx'  
  # s.osx.exclude_files = 'Classes/ios'  
  # s.public_header_files = 'Classes/**/*.h'  
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'  
  
end  
