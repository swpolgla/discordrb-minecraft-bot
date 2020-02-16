# This class manages reading the config file. This config file is strictly
# for configuring the droplets created by the bot. API access tokens are stored
# in separate files.
class CONFIG_MANAGER
    
    CONFIG_FILE_NAME = "config.txt"
    FRESH_CONFIG_FILE = "Droplet_Name=minecraft-bot-droplet\nServer_Region=nyc3\nDroplet_Specs=s-1vcpu-2gb\nOS_Image=ubuntu-18-04-x64\nDefault_Server=minecraft-bot-default"
    
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
        
        # Reads the config file into an array of strings
        @config_data = File.readlines(CONFIG_FILE_NAME)
            
        # This strips out the labels from each line, leaving only the data.
        # It's an ugly way of accomplishing this task but it works.
        @config_data[0] = @config_data[0][13..@config_data[0].length]
        @config_data[1] = @config_data[1][14..@config_data[1].length]
        @config_data[2] = @config_data[2][14..@config_data[2].length]
        @config_data[3] = @config_data[3][9..@config_data[3].length]
        @config_data[4] = @config_data[4][15..@config_data[4].length]
        return self
    end
    
    # Returns the name of the droplet the bot will create as a string
    def droplet_name
       return @config_data[0]
    end
    
    # Returns the server region the droplet will be created in as a string
    def server_region
       return @config_data[1]
    end
    
    # Returns the spec string of the droplet
    def droplet_specs
       return @config_data[2]
    end
    
    # Returns the os image string that the droplet will use
    def os_image
       return @config_data[3]
    end
    
    # Returns the name of the volume containing the server to be launched if
    # the /start command has no parameters
    def default_server
        return @config_data[4]
    end
    
end
