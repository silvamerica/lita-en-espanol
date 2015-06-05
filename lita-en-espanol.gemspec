Gem::Specification.new do |spec|
  spec.name          = "lita-en-espanol"
  spec.version       = "0.1.0"
  spec.authors       = ["Nicholas Silva"]
  spec.email         = ["nick@silvamerica.com"]
  spec.description   = "Carries on your conversation in another room, entirely in another language."
  spec.summary       = "Carries on your conversation in another room, entirely in another language."
  spec.homepage      = "https://github.com/silvamerica/lita-en-espanol"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.3"
  spec.add_runtime_dependency "microsoft_translator", "~> 0.2.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
