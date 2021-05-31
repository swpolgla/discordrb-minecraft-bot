require 'json'

# This class manages reading the config file. This config file is strictly
# for configuring the droplets created by the bot. API access tokens are stored
# in separate files.
class CONFIG_MANAGER
    
    CONFIG_FILE_NAME = "config/config.json"
    FRESH_CONFIG_FILE = '{\n'+
    '  "Droplet_Name": "minecraft-bot-droplet",\n'+
    '  "Droplet_Specs": "s-1vcpu-2gb",\n'+
    '  "OS_Image": "ubuntu-20-04-x64",\n'+
    '  "Default_Server": "minecraft-bot-default",\n'+
    '  \n'+
    '  "Information": "For the droplet specs/OS image, get the strings (slugs) from here:",\n'+
    '  "Link_To_Slugs": "https://slugs.do-api.dev/"\n'+
    '}';
    STARTUP_SCRIPT_FILE_NAME = "startup_script.txt"
    
    @config_data = nil
    
    # Generates a fresh config file if one doesn't exist, and then reads it
    def initialize
        unless File.exist?(CONFIG_FILE_NAME)
            File.write(CONFIG_FILE_NAME, FRESH_CONFIG_FILE)
            puts("\n------------------------------------------------------------")
            puts("A config file has been generated to store information about")
            puts("the the droplets you want to create each time /start is run")
            puts("and the volumes that store the data for each server.")
            puts("The default values are enough for a small server.")
            puts("------------------------------------------------------------")
        end
        
        # Open the config file for reading
        file = File.read(CONFIG_FILE_NAME)
        
        # Create a dictionary object from the JSON config file
        @config_data = JSON.parse(file)
        
        return self
    end
    
    # Returns the name of the droplet the bot will create as a string
    def droplet_name
        return @config_data['Droplet_Name']
    end
    
    # Returns the spec string of the droplet
    def droplet_specs
        return @config_data['Droplet_Specs']
    end
    
    # Returns the os image string that the droplet will use
    def os_image
        return @config_data['OS_Image']
    end
    
    # Returns the name of the volume containing the server to be launched if
    # the /start command has no parameters
    def default_server
        return @config_data['Default_Server']
    end
    
    # Parses startup_script.txt into a string and substitutes the correct volume
    # name into the commands that mount the storage volume with the server files.
    def startup_script(volume_name)
        script = File.read(STARTUP_SCRIPT_FILE_NAME)
        script = script.gsub("{VOLUME_NAME}", volume_name)
        return script
    end
end
