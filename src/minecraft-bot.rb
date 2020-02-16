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
doclient = DO_INTEGRATOR.new.create_client

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
    
    # Checks to see if the user has specified a custom volume to load
    if server == nil
        event.respond("Starting Default Server...")
    else
        event.respond("Starting " << server << "...")
    end
    isRunning = true
    bot.update_status("idle", "Server Startup", nil, 0, false, 3)
    
    # Begin creating droplet
    volume_name = config.default_server
    unless server == nil
        volume_name = server
    end
    volume_id = nil
    # Currently it isn't possible to request a specific volume by name using the
    # DigitalOcean api. This works around it by scanning every volume the bot can
    # access through their API for a matching name.
    doclient.volumes.all.each {
        |x|
        if x.name == config.default_server
           volume_id = x.id
           break
        end
    }
    
    # Searches all SSH keys on your Digital Ocean account for the word
    # "minecraft" in their name and stores them in an array. These SSH keys will
    # be embedded into the droplet.
    ssh_key_list = Array[]
    doclient.ssh_keys.all.each {
        |x|
        if x.name.include? "minecraft"
           ssh_key_list.push(x.fingerprint)
        end
    }

    # Creates a droplet using information from the config file. Embeds all SSH
    # keys present in your DigitalOcean account into the droplet by default.
    # It also attaches the volume containing the minecraft server files.
    droplet = DropletKit::Droplet.new(
      name: config.droplet_name,
      region: config.server_region,
      size: config.droplet_specs,
      image: config.os_image,
      ssh_keys: ssh_key_list,
      tags: ["minecraft-bot"],
      volumes: [volume_id]
    )
    doclient.droplets.create(droplet)
    
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
