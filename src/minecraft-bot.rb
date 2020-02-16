# This bot manages a specified Minecraft server hosted on DigitalOcean.
require 'discordrb'
require 'droplet_kit'
require_relative 'do_integrator'
require_relative 'config_manager'

DISCORD_API_TOKEN_FILE_NAME = "token.txt"

# The default string in token.txt when the user has not yet added their custom token
TOKEN_NOT_FOUND = "token=INSERT DISCORD BOT TOKEN HERE"

# Specifies whether there is currently a server online
isRunning = false

# Reads the config file and provides methods that return the values as strings
config = CONFIG_MANAGER.new

# DigitalOcean DropletKit client
doclient = DO_INTEGRATOR.new

if doclient == nil
   return
end

# Generates empty token/application ID files if they do not already exist
if !File.exist?(DISCORD_API_TOKEN_FILE_NAME)
    File.write(DISCORD_API_TOKEN_FILE_NAME, TOKEN_NOT_FOUND)
    puts("\n------------------------------------------------------------")
    puts("A file has been created to store your bot's unique token.")
    puts("This token can be found within your Discord Dev Portal.")
    puts("Please insert it into token.txt before continuing")
    puts("------------------------------------------------------------")
end

# Reads your specific application ID/token from their individual files
token = File.read("token.txt")
if token == TOKEN_NOT_FOUND
    puts("Please insert your bot's unique token into token.txt before continuing.")
    puts("This token can be found within your Discord Dev Portal.")
    return
end
token = token[6..token.length]

# Creates the bot with a token/application ID generated from your Discord
# Developer Portal.
bot = Discordrb::Commands::CommandBot.new token: token, prefix: '/'

# Prompt to invite the bot to your server if necessary
puts "\nInvite the bot to your server: #{bot.invite_url}\n\n"


### Bot Setup
## Bot commands are created here, and bot settings are specified before it
## is run.

# The /start command. Starts the default server if no server name is specified.
# @param server the name of the droplet to launch
bot.command :start do |event, server|
    
    # Prevent using the /start command if the server is already running
    if isRunning
       break
    end
    
    # Checks to see if the user has specified a custom droplet to start
    if server == nil
        event.respond("Starting Default Server")
    else
        event.respond("Starting " << server)
    end
    isRunning = true
    bot.update_status("idle", "Server Startup", nil, 0, false, 3)
    # Insert DigitalOcean start commands here
    return nil
end

bot.command :stop do |event|
    event.respond("Stopping Server...")
    bot.update_status("idle", "Server Shutdown", nil, 0, false, 3)
    # Insert DigitalOcean stop commands here
    return nil
end

### Bot Post Launch
## Methods that need to be called on the bot after it has established a
## connection to Discord are listed here.

bot.run(true)

# last int is status type. 0 - Playing, 1 - Streaming, 2 - Listening, 3 - Watching
bot.update_status("dnd", "Offline Server", nil, 0, false, 3)

bot.sync
