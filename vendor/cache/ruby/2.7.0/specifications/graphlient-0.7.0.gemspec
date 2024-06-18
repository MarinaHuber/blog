# -*- encoding: utf-8 -*-
# stub: graphlient 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "graphlient".freeze
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ashkan Nasseri".freeze]
  s.date = "2022-10-11"
  s.email = "ashkan.nasseri@gmail.com".freeze
  s.homepage = "http://github.com/ashkan18/graphlient".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "A friendlier Ruby client for consuming GraphQL-based APIs.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, ["~> 2.0"])
  s.add_runtime_dependency(%q<graphql-client>.freeze, [">= 0"])
end
