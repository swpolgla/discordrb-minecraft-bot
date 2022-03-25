require 'droplet_kit'
require 'json'


# This class provides a method to setup and return a DropletKit client.
class DO_INTEGRATOR
    
    # The name of the file that stores the DigitalOcean API access token
    DO_TOKEN_FILE_NAME = "config/token_digitalocean.json"
    
    # The default string in token_DO.txt when the user has not yet added their custom token
    TOKEN_NOT_FOUND = "{\n    \"token\": \"INSERT DIGITAL OCEAN TOKEN HERE\"\n}" 
    
    @token = TOKEN_NOT_FOUND
    
    # Initializes and returns a DropletKit client to access the DO api from.
    # @return nil if a valid API token cannot be found or hasn't been provided
    def create_client
        @token = readToken
        
        if @token == TOKEN_NOT_FOUND or @token == nil
            return nil
        end
        
        @token = JSON.parse(@token)["token"]
        
        return DropletKit::Client.new(access_token: @token)
        
    end
    
    # Reads your DigitalOcean API token from a file and returns it. Creates a
    # blank file in the event one doesn't exist.
    def readToken
        # Generates an empty API key file if one does not exist.
        if !File.exist?(DO_TOKEN_FILE_NAME)
            File.write(DO_TOKEN_FILE_NAME, TOKEN_NOT_FOUND)
            puts("\n------------------------------------------------------------")
            puts("A file has been created to store your DigitalOcean API token.")
            puts("This token can be found within your DigitalOcean account.")
            puts("Please insert it into token_digitalocean.json before continuing")
            puts("------------------------------------------------------------")
            return
        end
        
        # Reads your DigitalOcean API key from token_digitalocean.json
        token = File.read(DO_TOKEN_FILE_NAME)
        if token == TOKEN_NOT_FOUND
            puts("\n------------------------------------------------------------")
            puts("Please insert your DigitalOcean API access token into token_digitalocean.json before continuing.")
            puts("This token can be found within your DigitalOcean account.")
            puts("------------------------------------------------------------")
            return
        end
        return token
    end
end
