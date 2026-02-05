guard :standardrb, fix: false, all_on_start: false, progress: true do
  watch(/.+\.rb$/)
end

guard :minitest, all_on_start: false do
  watch(%r{^test/(.*/)?([^/]+)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$}) { |m|
    "test/#{m[1]}#{m[2]}_test.rb"
  }
  watch(%r{^test/test_helper\.rb$}) { "test" }
end
