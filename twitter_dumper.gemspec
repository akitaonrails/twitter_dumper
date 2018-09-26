
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "twitter_dumper/version"

Gem::Specification.new do |spec|
  spec.name          = "twitter_dumper"
  spec.version       = TwitterDumper::VERSION
  spec.authors       = ["Fabio Akita"]
  spec.email         = ["fabioakita@gmail.com"]

  spec.summary       = %q{Scrap the entire timeline from a Twitter user.}
  spec.description   = %q{Takes screenshots of the entire timeline of a Twitter user.}
  spec.homepage      = "https://github.com/akitaonrails/twitter_dumper"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "selenium-webdriver", "~> 3.14.0"
end
