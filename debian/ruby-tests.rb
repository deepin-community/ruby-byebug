require 'tmpdir'
ENV['BUNDLE_GEMFILE'] = '/dev/null'
require 'bundler'
require './test/minitest_runner.rb'

ARGV.push '--verbose'

$EXCLUDES = []
[
  'any',
  ENV['AUTOPKGTEST_TMP'] && 'autopkgtest' || nil,
  `dpkg-architecture -qDEB_HOST_ARCH`.strip,
].compact.each do |f|
  excludes = "debian/tests/exclude/#{f}"
  if File.exists?(excludes)
    $EXCLUDES += File.read(excludes).split
  end
end

class Byebug::MinitestRunner
  def all_test_suites
    Dir.glob("test/**/*_test.rb") - $EXCLUDES
  end
end

rc = 0
Dir.mktmpdir do |home|
  ENV['HOME'] = home
  rc = 1 unless Byebug::MinitestRunner.new.run
end

exit rc
