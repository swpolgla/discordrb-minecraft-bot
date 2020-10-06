FROM ruby:2.7.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle update --bundler

COPY . .
RUN chmod +x minecraft_bot.rb
RUN ls
RUN pwd
CMD ["/usr/local/bin/ruby", "minecraft_bot.rb"]
