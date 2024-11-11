# frozen_string_literal: true

module I18nTasks
  module Plugin
    module ViewComponent
      class ComponentErbScanner < I18n::Tasks::Scanners::ErbAstScanner
        def absolute_key(key, path, roots: config[:relative_roots],
                         exclude_method_name_paths: config[:relative_exclude_method_name_paths],
                         calling_method: nil)
          result = super

          result.gsub(/(\w+)\.(?=\1#{key})/, '')
        end
      end
    end
  end
end
