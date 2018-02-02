
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backupper/version'

Gem::Specification.new do |spec|
  spec.name          = 'backupper'
  spec.version       = Backupper::VERSION
  spec.authors       = ['pioz']
  spec.email         = ['epilotto@gmx.com']

  spec.summary       = %q{Tool to backup databases}
  spec.description   = %q{Tool to backup databases}
  spec.homepage      = 'https://github.com/uqido/backupper'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'sshkit', '~> 1.15'
  spec.add_runtime_dependency 'mail', '~> 2.7'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
