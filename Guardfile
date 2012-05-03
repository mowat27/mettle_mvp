# A sample Guardfile
# More info at https://github.com/guard/guard#readme

puts <<-EOS
Resetting the compiled sources
------------------------------
#{`rake coffee:test:reset`}

Starting guard
--------------
EOS

guard 'coffeescript', :output => 'public/javascripts/compiled', :all_on_start => true do
  watch(/^app\/assets\/javascripts\/(.*).coffee/)
end

guard 'coffeescript', :output => 'spec/javascripts/compiled', :all_on_start => true do
  watch(/^spec\/javascripts\/(.*).coffee/)
end

guard 'coffeescript', :input => 'spec/javascripts/helpers', :all_on_start => true