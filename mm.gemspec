MOMENTUM_VERSION = "0.2.2"

Gem::Specification.new do |spec|
  spec.name = "mm"
  spec.version = MOMENTUM_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "CLI for Madriska Momentum"
  spec.files =  Dir.glob("{examples,lib,spec,vendor,data,bin}/**/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"
  spec.executables = ["mm"]

  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = true
  spec.authors  = ["Gregory Brown", "Jordan Byron", "Brad Ediger"]
  spec.email    = ["gregory.t.brown@gmail.com", "jordan.byron@gmail.com",
                   "brad@bradedier.com"]
  spec.homepage = "http://momentum.madriska.com"
  spec.description = "CLI for Madriska Momentum"

  spec.add_dependency "highline", ">= 1.6.20"
  spec.add_dependency "rest-client", ">= 1.7.2"
  spec.add_dependency "json"
end
