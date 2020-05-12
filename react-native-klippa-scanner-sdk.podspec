require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-klippa-scanner-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-klippa-scanner-sdk
                   DESC
  s.homepage     = "https://github.com/klippa-app/react-native-klippa-scanner-sdk"
  s.license      = "MIT"
  s.authors      = { "Jeroen Bobbeldijk" => "jeroen@klippa.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/klippa-app/react-native-klippa-scanner-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "Klippa-Scanner"
end

