# frozen_string_literal: true

require 'i18n/tasks'

module I18nTasks
  module Plugin
    module ViewComponent
      class Filesystem < ::I18n::Tasks::Data::FileSystemBase
        register_adapter :yaml, '*.yml', ::I18n::Tasks::Data::Adapter::YamlAdapter
        register_adapter :json, '*.json', ::I18n::Tasks::Data::Adapter::JsonAdapter

        def initialize(config) # rubocop:disable Metrics/MethodLength
          @view_component_root = config.fetch(:view_component_root, 'app/components').gsub(%r{/$}, '')

          erb_conf = I18n::Tasks::UsedKeys::SEARCH_DEFAULTS[:scanners].find do |s|
            s[0] == '::I18n::Tasks::Scanners::ErbAstScanner'
          end

          if erb_conf
            erb_conf[1][:exclude] ||= []
            erb_conf[1][:exclude].push(component_root_erb_pattern)
          end

          super

          I18n::Tasks.add_scanner(
            'I18nTasks::Plugin::ViewComponent::ComponentErbScanner',
            only: [component_root_erb_pattern]
          )
        end

        ##
        # Overloaded from `I18n::Tasks::Data::FileFormats` (included in `I18n::Tasks::Data::FileSystemBase`)
        #
        # In component-local locale files, it adds the component's module hierarchy to the locale scope,
        # as does `ViewComponent::Translatable`.
        #
        # Locale files outside the ViewComponent directory are not modified.
        #
        def load_file(path)
          result = super

          return result unless component_locale_data?(path)

          locale    = result.keys.first
          key_parts = [locale, *component_keys(path)]

          key_parts.reverse.inject(result[locale]) { |akk, key| { key => akk } }
        end

        ##
        # Overloaded from `I18n::Tasks::Data::FileFormats` (included in `I18n::Tasks::Data::FileSystemBase`)
        #
        # This is the reverse method of `#load_file` above.
        # It takes a locale tree and removes the scope of the component.
        #
        # As above, locale files outside the ViewComponent directory are not modified.
        #
        def normalized?(path, tree)
          if component_locale_data?(path)
            super(path, tree_without_component_keys(path, tree))
          else
            super
          end
        end

        ##
        # Overloaded from `I18n::Tasks::Data::FileFormats` (included in `I18n::Tasks::Data::FileSystemBase`)
        #
        # This is needed to reverse the effects i18n-task's standard router has in locale files inside ViewComponent's
        # directories when invoking `i18n-tasks normalize`.
        #
        # As above, locale files outside the ViewComponent directory are not modified.
        #
        def write_tree(path, tree, sort = nil)
          if component_locale_data?(path)
            super(path, tree_without_component_keys(path, tree))
          else
            super
          end
        end

        private

        def component_locale_data?(path)
          path.start_with?(@view_component_root)
        end

        def component_keys(path)
          root_dir_levels = @view_component_root.split('/').size

          components = File.dirname(path).split('/')[root_dir_levels..]

          basename = File.basename(path).gsub(/(\.\w{2})?\.yml$/, '')

          components << basename unless components.last == basename

          components
        end

        def tree_without_component_keys(path, tree)
          new_tree = tree.dup

          new_tree.list.first.children = component_keys(path).inject(new_tree.list.first) { |akk, el| akk[el] }.children

          new_tree
        end

        def component_root_erb_pattern
          @component_root_erb_pattern ||= "#{@view_component_root}/**/*.erb"
        end
      end
    end
  end
end
