# frozen_string_literal: true

$:.unshift(File.expand_path('/lib', __FILE__))
require_relative 'lib/root/version'

Gem::Specification.new do |spec|
  spec.name          = 'root'
  spec.version       = Root::VERSION
  spec.authors       = ['ayellapragada']
  spec.email         = ['ayellapragada@gmail.com']

  spec.summary       = 'A game of magical forest creatures.'
  # spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/ayellapragada'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = "TODO: Your gem's CHANGELOG.md URL here."
  spec.metadata['changelog_uri'] = spec.homepage
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency('rainbow')
end
