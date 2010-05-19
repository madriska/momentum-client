TEMPO_VERSION = "0.0.1" 

Gem::Specification.new do |spec|
  spec.name = "turbine"
  spec.version = TEMPO_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A seecret"
  spec.files =  Dir.glob("{examples,lib,spec,vendor,data,bin}/**/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"
  spec.executables = ["turbine"]

  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = true
  spec.author = "Gregory Brown"
  spec.email = "  gregory.t.brown@gmail.com"
  spec.homepage = "http://pixelpowerhouse.com"
  spec.description = <<END_DESC
  Seeekrit
END_DESC
end
