export BUNDLE_PATH=.gems
export BUNDLE_BIN_PATH=.gems
bundle update --bundler
bundle install
bundle exec ruby minecraft_bot.rb
