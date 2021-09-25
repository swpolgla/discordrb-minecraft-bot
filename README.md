# discordrb-minecraft-bot
A discord bot written in Ruby that manages minecraft servers hosted on DigitalOcean. Uses the discordrb library for bot functionality.

The purpose of this bot is to work around DigitalOcean's pricing system. Droplets are billed by the second, even when they're turned off. For a small Minecraft server this is not ideal. There's no reason to pay 24/7 for a server that you use for a few hours at a time.

# Setup
The bot will generate some config files on first launch. It needs a Discord API access token, and a DigitalOcean API token with read AND write permissions. Put those in their respective files.

The bot stores your Minecraft server data on DigitalOcean "volumes". This allows your server data to persist even after a droplet has been destroyed. Your server files must be laid out in a specific way in order for the bot to function. (In the future this will be simplified.)

### To create your first server volume follow these steps:
- From your DigitalOcean account, create a droplet. The default Ubuntu distro and the cheapest specs are just fine. You'll only need it for a few minutes. Please make sure you pick the correct region. Volumes CANNOT be moved across DigitalOcean server regions, and the region you choose for this droplet will decide where the volume created in the next step is located.
- Once the droplet is booted up, go to the "Volumes" tab in DigitalOcean. Create a volume with enough space to store your server files, and attach it to the droplet you created in the prior step. The name you choose for the volume is permanent, and case sensitive. Do not use spaces. The default name is `minecraft-bot-default`
- Ensure that your server files include a starup script named `start.sh`. This should include the java terminal command you want to use to start the server. The bot will not work without this.
- Using SSH/Filezilla or any other method, login to the droplet using the IP listed next to the droplet within your DigitalOcean account. Upload your server files to `/mnt/minecraft-bot-default` (start.sh should be directly within that folder)
- Shut down and destroy the droplet, but do NOT delete the volume.
- You can now run /start from a channel that the bot is in. It will create a new droplet with the name/region/specs specified in the config file, mount the minecraft-bot-default volume and run the start.sh file. (The default volume to launch can be modified within the config file.) Your server is now running. The bot will send the server IP in chat.
- When you're finished with the server, run /stop from a channel that the bot is in. It will stop the minecraft server, gracefully shut down the droplet, and destroy it afterwards. If you forget to shut off your server, don't worry! The bot has you covered. If your server has 0 players online for 10 minutes the bot will automatically shut it down for you.

This process can be repeated as many times as you want. If you provide the /start command with an argument, you can specify the name of the volume that the bot will start. Ex: `/start tekkit-classic` would start a different server than `/start vanilla-survival` To view a list of available volumes use `/servers` Please note that only one server can be active at a time.

# How to start the bot
Install ruby from https://www.ruby-lang.org/en/downloads/ or by using your package manager.
I won't provide instructions on how to install it or set it up.
You'll need the full or dev versions of ruby. On Ubuntu the package is labeled as `ruby-full`
Additionally, you'll need to install bundler to install dependencies. On Ubuntu the package is labeled as `bundler`
I've personally used Ruby 2.6.3 while developing the bot, however anything newer than 2.5 should work fine.
If anything newer *doesn't* work, please let me know!

The version provided with newer versions of MacOS is sufficient.

Once you've got ruby installed, it should be as simple as running `start.sh`

You'll be prompted to insert your DigitalOcean and Discord API keys into their config files, but then things should just work.

# Other Important Info:
- The first time you run the bot, bundler will need to compile a couple of ruby gems with native extensions. This process requires 1GB of RAM at minimum to complete or it will fail with an incoherent error message.
- The bot will automatically transfer all SSH keys stored in your DigitalOcean account that contain "minecraft" in their name to any droplets it creates.
- All droplets created by the bot are tagged with "minecraft-bot" within DigitalOcean.

### Can I invite the bot to my Discord server without self-hosting it?
No. The bot is highly specialized and it would require me to pay to store your server files and run your server. If you'd like a way to run the bot 24/7 for free, check out https://cloud.google.com/free
GCP will provide you with an e2-micro compute instance 100% free of charge. It's not very powerful, but it's more than capable of hosting this bot. You could also host the bot on the cheapest DigitalOcean droplet possible, but $5/month is infinitely more than $0/month.
