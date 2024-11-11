# frozen_string_literal: true

require_relative 'lib/i18n_tasks/plugin/view_component/version'

Gem::Specification.new do |spec|
  spec.name = 'i18n_tasks-plugin-view_component'
  spec.version = I18nTasks::Plugin::ViewComponent::VERSION
  spec.authors = ['Jochen Lutz']
  spec.email = ['jochen.lutz@ionos.com']

  spec.summary = 'Integrate ViewComponent with I18n-Tasks'
  spec.description = 'support for View Component (https://viewcomponent.org/) in i18n-tasks (https://github.com/glebm/i18n-tasks)'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['source_code_uri'] = 'https://github.com/ionos-cloud/i18n-tasks-view-component'
  spec.homepage = spec.metadata['source_code_uri']
  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'i18n-tasks', '~> 1.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
