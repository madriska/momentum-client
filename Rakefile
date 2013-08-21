require 'rake'

require 'rubygems/package_task'

spec = Gem::Specification.load "mm.gemspec"
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
