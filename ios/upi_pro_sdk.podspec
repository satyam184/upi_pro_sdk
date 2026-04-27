Pod::Spec.new do |s|
  s.name             = 'upi_pro_sdk'
  s.version          = '0.1.0'
  s.summary          = 'Production-grade UPI SDK for Flutter.'
  s.description      = <<-DESC
UPI SDK with robust app discovery, payment launch, and response handling.
                       DESC
  s.homepage         = 'https://example.com/upi_pro_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'UPI Pro SDK' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.swift_version = '5.0'
end
