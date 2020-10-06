FROM ruby:2.7.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY src/Gemfile src/Gemfile.lock ./
RUN bundle update --bundler

COPY . .
WORKDIR src
RUN chmod +x minecraft_bot.rb
CMD ["/usr/local/bin/ruby", "minecraft_bot.rb"]
