# The minestat gem has some kind of permissions issue.
# So we just install the gems locally and ensure that
# the current user can infact read all of them.
export BUNDLE_PATH=.gems
export BUNDLE_BIN_PATH=.gems
bundle update --bundler
bundle install
chmod -R u+r .gems
bundle exec ruby minecraft_bot.rb
