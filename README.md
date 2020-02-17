# discordrb-minecraft-bot
A discord bot written in Ruby that manages minecraft servers hosted on DigitalOcean. Uses the discordrb library for bot functionality.

The purpose of this bot is to work around DigitalOcean's pricing system. Droplets are billed by the second, even when they're turned off. For a small Minecraft server this is not ideal. There's no reason to pay 24/7 for a server that you use for a few hours at a time.

# Setup
The bot will generate some config files on first launch. It needs a Discord API access token, and a DigitalOcean API token with read AND write permissions. Put those in their respective files.

The bot stores your Minecraft server data on DigitalOcean "volumes". This allows your server data to persist even after a droplet has been destroyed. Your server files must be laid out in a specific way in order for the bot to function. (In the future this will be simplified.)

To create your first server volume follow these steps:
- From your DigitalOcean account, create a droplet. The default Ubuntu distro and the cheapest specs are just fine. You'll only need it for a few minutes. Please make sure you pick the correct region. Volumes CANNOT be moved across DigitalOcean server regions, and the region you choose for this droplet will decide where the volume created in the next step is located.
- Once the droplet is booted up, go to the "Volumes" tab in DigitalOcean. Create a volume with enough space to store your server files, and attach it to the droplet you created in the prior step. Name it "minecraft-bot-default". (If you want to name it differently, you can edit the config file.)
- Ensure that your server files include a starup script named "start.sh". This should include the java terminal command you want to use to start the server. The bot will not work without this.
- Using SSH/Filezilla or any other method, login to the droplet using the IP listed next to it within your DigitalOcean account. Upload your server files to /mnt/minecraft-bot-default (start.sh should be directly within that folder)
- Shut down and destroy the droplet, but do NOT delete the volume.
- You can now run /start from a channel that the bot is in. It will create a new droplet with the name/region/specs specified in the config file, mount the minecraft-bot-default volume and run the start.sh file. Your server is now running. The bot will send the server IP in chat.
- When you're finished with the server, run /stop from a channel that the bot is in. It will stop the minecraft server, gracefully shut down the droplet, and destroy it afterwards.

This process can be repeated as many times as you want. If you provide the /start command with an argument, you can specify the name of the volume that the bot will start. Ex: "/start minecraft-bot-survival" would start a different server than "/start minecraft-bot-default". Please note that only one server can be active at a time.

# Other Important Info:
- The bot will automatically transfer all SSH keys stored in your DigitalOcean account to any droplets it creates, that contain "minecraft" in their name.
- All droplets created by the bot are tagged with "minecraft-bot" within DigitalOcean.

### Can I invite the bot to my server without self-hosting it?
No. The bot is highly specialized and it would require me to pay to store your server files and run your server. That's far too much work. If you'd like a way to run the bot 24/7 for free, check out https://cloud.google.com/free
GCP will provide you with an f1-micro compute instance 100% free of charge. It's not very powerful, but it's more than capable of hosting this bot. You could also host the bot on the cheapest DigitalOcean droplet possible, but $5/month is infinitely more than $0/month.
