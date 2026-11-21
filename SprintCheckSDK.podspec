Pod::Spec.new do |s|
  s.name             = 'SprintCheckSDK'
  s.version          = '1.0.0'
  s.summary          = 'SprintCheck iOS SDK for Identity Verification, BVN, NIN, and Facial Liveness Recognition.'
  s.homepage         = 'https://github.com/odejinmi/sprintcheckios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '5 Star Company' => 'info@sprintcheck.com' }
  s.source           = { :git => 'https://github.com/odejinmi/sprintcheckios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.9'

  s.source_files = 'SprintCheckSDK/**/*'
  s.frameworks   = 'UIKit', 'SwiftUI', 'AVFoundation', 'Vision', 'CommonCrypto'

  s.dependency 'FaceSDK'
end
