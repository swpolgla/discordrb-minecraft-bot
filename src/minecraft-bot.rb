# This bot manages a specified Minecraft server hosted on DigitalOcean.
require 'discordrb'

# Generates empty token/application ID files if they do not already exist
if !File.exist?("token.txt") or !File.exist?("appID.txt")
    File.write("token.txt", "appID=INSERT DISCORD BOT TOKEN HERE")
    File.write("appID.txt", "appID=INSERT APPLICATION ID HERE")
    puts("Files have been created to store your bot's unique token and application ID. \nPlease place the necessary information into those files.")
    return


# Reads your specific application ID/token from their individual files
token = File.read("/token.txt")
appID = File.read("/appID.txt")

# Creates the bot with a token/application ID generated from your Discord
# Developer Portal.
# bot = Discordrb::Bot.new token: token

# Prompt to invite the bot to your server if necessary
puts "Invite the bot to your server:" # {bot.invite_url}"
end
