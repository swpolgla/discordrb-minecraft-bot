# This bot manages a specified Minecraft server hosted on DigitalOcean.
require 'discordrb'
require 'droplet_kit'
require 'minestat'
require 'rufus-scheduler'
require_relative 'do_integrator'
require_relative 'config_manager'

DISCORD_API_TOKEN_FILE_NAME = "config/token_discord.txt"

# The default string in token.txt when the user has not yet added their custom token
TOKEN_NOT_FOUND = "token=INSERT DISCORD BOT TOKEN HERE"

# Specifies whether there is currently a server online
isRunning = false

# Every 10 minutes if the server is active, the Minecraft server is pinged to check
# player count. If the player count is 0 for 2 consecutive checks, the server is
# stopped.
playersOnline = true

# The server's IP address as a string. Used for getting stats.
serverIP = nil

# Reads the config file and provides methods that return the values as strings
config = CONFIG_MANAGER.new

# An instance of the Rufus scheduler. Handles server auto shutdown.
scheduler = Rufus::Scheduler.new
# The job ID for server auto shutdown. Created in /start command, erased in /stop command
# or after server auto shutdown.
autoShutdownJobID = nil

# DigitalOcean DropletKit client
doclient = DO_INTEGRATOR.new.create_client

if doclient == nil
   return
end


# Generates empty token/application ID files if they do not already exist
if !File.exist?(DISCORD_API_TOKEN_FILE_NAME)
    File.write(DISCORD_API_TOKEN_FILE_NAME, TOKEN_NOT_FOUND)
    puts("\n------------------------------------------------------------")
    puts("A file has been created to store your bot's Discord API token.")
    puts("This token can be found within your Discord Dev Portal.")
    puts("Please insert it into token.txt before continuing")
    puts("------------------------------------------------------------")
    return
end

# Reads your specific application ID/token from their individual files
token = File.read(DISCORD_API_TOKEN_FILE_NAME)
if token == TOKEN_NOT_FOUND
    puts("\n------------------------------------------------------------")
    puts("Please insert your bot's Discord API token into token.txt before continuing.")
    puts("This token can be found within your Discord Dev Portal.")
    puts("------------------------------------------------------------")
    return
end
token = token[6..token.length]

# Creates the bot with a token/application ID generated from your Discord
# Developer Portal.
bot = Discordrb::Commands::CommandBot.new token: token, prefix: '/'

# Prompt to invite the bot to your server if necessary
puts("------------------------------------------------------------")
puts ("\nInvite the bot to your server: #{bot.invite_url}\n\n")
puts("------------------------------------------------------------")

### Bot Setup
## Bot commands are created here, and bot settings are specified before it
## is run.

# The /start command. Starts the default server if no server name is specified.
# @param server the name of the droplet to launch
bot.command(:start, chain_usable: false, description: "Starts a server. `/start <volume_name>`") do |event, server|
    
    # Prevent using the /start command if the server is already running
    if isRunning
        break
    end
    
    isRunning = true
    
    
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
        if x.name == volume_name
            volume_id = x.id
            break
        end
    }
    
    if volume_id == nil
        response = "The specified server volume does not exist on your DigitalOcean account.\n"
        response += "Please input a valid volume name. For a list of available volumes, use `/servers`"
        
        event.channel.send_embed do |embed|
          embed.title = "Error Starting Server"
          embed.colour = 0xd54712
          embed.description = response
        end
        
        isRunning = false
        return
    end
    bot.update_status("idle", "Server Startup", nil, 0, false, 3)
    
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
    # keys containing "minecraft" in their name.
    # It also attaches the volume containing the minecraft server files.
    # The contents of startup_script.txt are uploaded and run as soon as the
    # droplet boots. It is what makes the minecraft server start.
    droplet = DropletKit::Droplet.new(
      name: config.droplet_name,
      region: config.server_region,
      size: config.droplet_specs,
      image: config.os_image,
      ssh_keys: ssh_key_list,
      tags: ["minecraft-bot"],
      user_data: config.startup_script(volume_name),
      volumes: [volume_id]
    )
    droplet = doclient.droplets.create(droplet)
    
    # Finds and prints the IPv4 address of the server to chat
    net = doclient.droplets.find(id: droplet.id).networks.v4[0]
    
    # In the event the DigitalOcean API is a bit slow, wait on it to catch up
    while net == nil
       sleep(5)
       net = doclient.droplets.find(id: droplet.id).networks.v4[0]
    end
    
    # Sends embed message
    serverIP = net.ip_address
    response = "**Server IP:** `#{net.ip_address}`\n"
    response += "Please be aware that the server may take several minutes to finish starting up.\n"
    response += "Your Minecraft client might say the server is using an 'old' version of the game during this time.\n"
    
    serverName = "Default Server"
    unless server == nil
       serverName = server
    end
    
    event.channel.send_embed do |embed|
      embed.title = "Starting " + serverName + "..."
      embed.colour = 0x7ed321
      embed.description = response
    end
    
    while true
        sleep(60)
        msClient = MineStat.new("#{net.ip_address}", 25565)
        if msClient.online
            bot.update_status("online", "#{msClient.current_players}/#{msClient.max_players} Players Online", nil, 0, false, 3)
            break
        end
    end
    
    

    # Every 5 minutes if the server is running, the bot will ping the Minecraft Server
    # to check the number of active players. It will then Update its status to display
    # it. This also performs a check for current players. If after 10 minutes 0 players
    # have been online, the server is shutdown.
    autoShutdownJobID = scheduler.every '1m' do
        msClient = MineStat.new("#{serverIP}", 25565)
        puts "5M CHECK GO BRBRBRBRBRBRBBR"
        if msClient.online
            bot.update_status("online", "#{msClient.current_players}/#{msClient.max_players} Players Online", nil, 0, false, 3)
            
            # Runs the equivalent of /stop if 0 players have been online for 10 minutes.
            # TODO - refactor to prevent code duplication
            unless playersOnline
                isRunning = false
                
                bot.update_status("idle", "Server Shutdown", nil, 0, false, 3)
                
                doclient.droplet_actions.shutdown_for_tag(tag_name: "minecraft-bot")
                
                sleep(20)
                doclient.droplets.delete_for_tag(tag_name: "minecraft-bot")
                bot.update_status("dnd", "Offline Server", nil, 0, false, 3)
                
                job = scheduler.job(autoShutdownJobID)
                job.unschedule
                playersOnline = true
                autoShutdownJobID = nil
                next
            end
            
            if msClient.current_players.to_s == "0"
                playersOnline = false
            else
                playersOnline = true
            end
        end
    end
    
    return nil
end

bot.command(:debug, chain_usable: false) do |event|
    event.respond("Shutdown Job: #{autoShutdownJobID}")
    event.respond("players Online: #{playersOnline}")
end

# Sends a shutdown signal to the droplet that is currently running. This will
# trigger a stop command on the minecraft server, and then gracefully shut down
# the droplet. After 20 seconds have passed the droplet is destroyed, along with
# any files not stored on the server data volume.
bot.command(:stop, chain_usable: false, description: "Stops the currently running server.") do |event|
    
    unless isRunning
        return "No servers are currently running."
    end
    
    job = scheduler.job(autoShutdownJobID)
    job.unschedule
    playersOnline = true
    autoShutdownJobID = nil
    
    isRunning = false
    
    event.respond("Stopping Server...")
    bot.update_status("idle", "Server Shutdown", nil, 0, false, 3)
    
    doclient.droplet_actions.shutdown_for_tag(tag_name: "minecraft-bot")
    
    sleep(20)
    doclient.droplets.delete_for_tag(tag_name: "minecraft-bot")
    bot.update_status("dnd", "Offline Server", nil, 0, false, 3)
    
    return nil
end

# Sends a restart command to the droplet. This is useful for when the Minecraft
# server crashes.
# TODO - Fix the startup script not being run when the droplet boots back up.
bot.command :reset do |event|
    
    unless isRunning
        return "No servers are currently running."
    end
    
    event.respond("Resetting server instance...")
    bot.update_status("away", "Server Reset in Progress...", nil, 0, false, 3)
    
    doclient.droplets.all(tag_name: "minecraft-bot").each {
        |x|
        doclient.droplet_actions.reboot(droplet_id: x.id)
    }
    sleep(30)
    bot.update_status("online", "0 Players Online", nil, 0, false, 3)
    
    return nil
end

# Pings the minecraft server and returns the player count and MOTD.
bot.command(:status, chain_usable: false, description: "Displays server player count and MOTD.") do |event|
    
    unless isRunning
        return "No servers are currently running."
    end
    
    msClient = MineStat.new("#{serverIP}", 25565)
    
    unless msClient.online
        return "Server ping failed."
    end
    
    event.channel.send_embed do |embed|
      embed.title = "#{msClient.current_players}/#{msClient.max_players} Players Online"
      embed.colour = 0x7ed321
      embed.description = "#{msClient.motd}"

    end
    return nil
end

# Polls the DigitalOcean API for server volume names and returns them in chat
bot.command(:servers, chain_usable: false, description: "Displays all available server volumes.") do |event|
   
   response = ""
   doclient.volumes.all.each {
       |x|
       response += "`" + x.name + "`\n"
   }
   
   event.channel.send_embed do |embed|
     embed.title = "Available Server Volumes: (Case Sensitive)"
     embed.colour = 0x7ed321
     embed.description = response

   end
   return nil
end

### Bot Post Launch
## Methods that need to be called on the bot after it has established a
## connection to Discord are listed here.

bot.run(true)

# last int is status type. 0 - Playing, 1 - Streaming, 2 - Listening, 3 - Watching
bot.update_status("dnd", "Offline Server", nil, 0, false, 3)

bot.sync
