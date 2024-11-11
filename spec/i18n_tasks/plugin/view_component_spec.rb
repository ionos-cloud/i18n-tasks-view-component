# frozen_string_literal: true

require 'tmpdir'
require 'i18n/tasks/cli'

RSpec.describe I18nTasks::Plugin::ViewComponent do
  shared_examples_for 'a healthy run' do
    subject(:health_result) { I18n::Tasks::CLI.new.run(%w[health]) }

    it 'is healthy' do
      expect(health_result).not_to eq(:exit1)
    end
  end

  shared_examples_for 'an unhealthy run' do
    subject(:health_result) { I18n::Tasks::CLI.new.run(%w[health]) }

    it 'is unhealthy' do
      expect(health_result).to eq(:exit1)
    end
  end

  let(:temp_dir) { copy_temp_fixture_app }

  before do
    setup_temp_dir(temp_dir)
  end

  after do
    remove_temp_dir
  end

  it 'has a version number' do
    expect(I18nTasks::Plugin::ViewComponent::VERSION).not_to be nil
  end

  context 'for a normal component' do
    it_behaves_like 'a healthy run'
  end

  context 'with a sidecar directory' do
    let(:temp_dir) do
      copy_temp_fixture_app do |dir|
        component_dir = "#{dir}/test_app1/app/components"
        sidecar_dir   = "#{component_dir}/demo_component"
        sidecar_files = %i[demo_component.html.erb demo_component.de.yml demo_component.en.yml].map do |file|
          "#{component_dir}/#{file}"
        end

        FileUtils.mkdir sidecar_dir
        FileUtils.mv sidecar_files, sidecar_dir
      end
    end

    it_behaves_like 'a healthy run'
  end

  context 'when using external keys' do
    let(:temp_dir) do
      copy_temp_fixture_app do |dir|
        component_dir = "#{dir}/test_app1/app/components"

        append_lines("#{component_dir}/demo_component.html.erb", "\n<div><%= t('global.key') %></div>")
        create_file("#{dir}/test_app1/config/locales/de.yml", [
          '---',
          'de:',
          '  global:',
          '    key: Wert',
          ''
        ].join("\n"))
        create_file("#{dir}/test_app1/config/locales/en.yml", [
          '---',
          'en:',
          '  global:',
          '    key: Value',
          ''
        ].join("\n"))
      end
    end

    it_behaves_like 'a healthy run'
  end

  context 'with missing keys' do
    let(:temp_dir) do
      copy_temp_fixture_app do |dir|
        component_dir = "#{dir}/test_app1/app/components"

        append_lines("#{component_dir}/demo_component.html.erb", '<div><%= t(".zz_missing_key") %></div>')
      end
    end

    it_behaves_like 'an unhealthy run'
  end

  context 'with unused keys' do
    let(:temp_dir) do
      copy_temp_fixture_app do |dir|
        component_dir = "#{dir}/test_app1/app/components"

        append_lines("#{component_dir}/demo_component.de.yml", "  unused: unbenutzt\n")
        append_lines("#{component_dir}/demo_component.en.yml", "  unused: unused\n")
      end
    end

    it_behaves_like 'an unhealthy run'
  end

  context 'with non-normalized keys' do
    let(:temp_dir) do
      copy_temp_fixture_app do |dir|
        component_dir = "#{dir}/test_app1/app/components"

        append_lines("#{component_dir}/demo_component.html.erb", "\n<div><%= t('.at_end') %></div>")
        append_lines("#{component_dir}/demo_component.de.yml", "  at_end: am Ende\n")
        append_lines("#{component_dir}/demo_component.en.yml", "  at_end: at end\n")
      end
    end

    it_behaves_like 'an unhealthy run'
  end

  context 'when calling normalize' do
    before { I18n::Tasks::CLI.new.run(%w[normalize]) }

    context 'on already normalized data' do
      it "does not include the component's name in the scope" do
        original_content = File.read(component_file_path('de.yml', use_temp_base_path: false))
        current_content  = File.read(component_file_path('de.yml', use_temp_base_path: true))

        expect(original_content).to eq(current_content)
      end
    end
  end
end

def copy_temp_fixture_app
  @tmp_dir = Dir.mktmpdir

  FileUtils.cp_r('spec/fixtures/test_app1/', @tmp_dir)

  yield @tmp_dir if block_given?

  "#{@tmp_dir}/test_app1"
end

def setup_temp_dir(dir)
  @pwd_before = Dir.pwd
  Dir.chdir(dir)
end

def remove_temp_dir
  Dir.chdir(@pwd_before)

  FileUtils.remove_entry(@tmp_dir)
end

def append_lines(file_path, *lines)
  content = File.read(file_path)

  content = %(#{content}#{lines.join("\n")})

  File.write(file_path, content)
end

def create_file(file_path, content)
  FileUtils.mkdir_p(File.dirname(file_path))
  File.write(file_path, content)
end

def component_file_path(type, use_temp_base_path: true)
  base_path = if use_temp_base_path
                "#{@pwd_before}/spec/fixtures"
              else
                @tmp_dir
              end

  "#{base_path}/test_app1/app/components/demo_component.#{type}"
end
