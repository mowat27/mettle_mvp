require 'fileutils'

namespace :coffee do
  namespace :test do
    desc "delete all compiled coffeescripts"
    task :reset do
      compiled_sources = ["public/javascripts/compiled", "spec/javascripts/compiled", "spec/javascripts/helpers/SpecHelper.js"]
      compiled_sources.each do |source|
        puts "removing #{source}"
        FileUtils.rm_rf source
      end
    end
  end
end