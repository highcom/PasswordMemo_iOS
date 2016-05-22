# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
# use_frameworks!

target 'PasswordMemo' do
post_install do | installer |
  require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-PasswordMemo/Pods-PasswordMemo-acknowledgements.plist', 'PasswordMemo/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
end

target 'PasswordMemoTests' do

end

target 'PasswordMemoUITests' do

end

