# This bot manages a specified Minecraft server hosted on DigitalOcean.
require 'discordrb'
require 'droplet_kit'

TOKEN_NOT_FOUND = "token=INSERT DISCORD BOT TOKEN HERE"
APPID_NOT_FOUND = "appID=INSERT APPLICATION ID HERE"

# Generates empty token/application ID files if they do not already exist
if !File.exist?("token.txt") or !File.exist?("appID.txt")
    File.write("token.txt", TOKEN_NOT_FOUND)
    File.write("appID.txt", APPID_NOT_FOUND)
    puts("Files have been created to store your bot's unique token and application ID. \nPlease place the necessary information into those files.")
end

# Reads your specific application ID/token from their individual files
token = File.read("token.txt")
if token == TOKEN_NOT_FOUND
    puts("Please insert your bot's unique token into token.txt before continuing.")
    puts("This token can be found within your Discord Dev Portal.")
    return
end
token = token[6..token.length]

appID = File.read("appID.txt")
if token == TOKEN_NOT_FOUND
    puts("Please insert your bot's Application ID into appid.txt before continuing.")
    puts("This token can be found within your Discord Dev Portal.")
    return
end
appID = appID[6..appID.length]

# Creates the bot with a token/application ID generated from your Discord
# Developer Portal.
bot = Discordrb::Bot.new token: token

# Prompt to invite the bot to your server if necessary
puts "Invite the bot to your server:" # {bot.invite_url}"

bot.message(content: '/start') do |event|
    event.respond 'Server Starting'
end
bot.run
