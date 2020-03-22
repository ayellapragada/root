# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in root.gemspec
gemspec

# DEV
gem 'byebug', '~> 11.0'
gem 'rake', '~> 12.0'
gem 'sandi_meter', require: :false

# TEST
gem 'guard', '~> 2.0'
gem 'guard-rspec', '~> 4.0'
gem 'rspec', '~> 3.0'
gem 'rubocop', '~> 0.80.0', require: false
gem 'rubocop-rspec', '~> 1.38', require: false
gem 'simplecov', require: false
gem 'turnip', '~> 4.0'

# This is to avoid a warning due to other upgrades and pry not being fixed.
gem 'pry', git: 'https://github.com/pry/pry.git', ref: '272b3290b5250d28ee82a5ff65aa3b29b825e37b'
gem 'pry-byebug', '~> 3.0'
