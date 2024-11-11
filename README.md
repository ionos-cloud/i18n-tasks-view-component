# I18nTasks::Plugin::ViewComponent

This gem adds support for [View Component](https://viewcomponent.org/)
to [i18n-tasks](https://github.com/glebm/i18n-tasks).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n_tasks-plugin-view_component', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install i18n_tasks-plugin-view_component

## Usage

Include the gem in your `i18n-tasks.yml.erb`. If you have a `i18n-tasks.yml`, just rename it.

```erb
<% require 'i18n_tasks/plugin/view_component' %>
```

Add the following config to the `data:` section.

```yaml
  adapter: I18nTasks::Plugin::ViewComponent::Filesystem
```

If you store your components somewhere different from the default `app/components`,
add the base directory also to the `data:` section.

```
  view_component_root: app/components
```

## Compatibility Details

While translations in the View Components's ruby code work (since the addition of
`relative_exclude_method_name_paths` in i18n-tasks version 1.0.10), putting
the locale files with the component code does not work, as these locale files
put all strings directly beneath the language key:

```
# app/components/demo_app/example_component.yml
en:
  hello: "Hello world!"
```

I18n-tasks scans this as `hello`, while ViewComponent prefixes all strings with
the component's fully qualified classname: `demo_app.example_component.hello`.
This scope `demo_app.example_component` is used to resolve all relative i18n
keys.

This plugin adds logic to i18n-tasks to put the locale strings in the correct
scope while loading the data.

Additionally, it also adds a scanner for `.erb` files, that correctly handles
files in sidecar directories, where vanilla i18n-tasks resolves the scope with
the component's name duplicated. E.g. `t('.hello')` in
`app/components/demo_app/example_component/example_component.html.erb` leads to
`demo_app.example_component.example_component.hello` with vanilla i18n-tasks,
while with this plugin, it resolves to `demo_app.example_component.hello`,
which ViewComponent uses internally.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/ionos-cloud/i18n-tasks-view-component).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
