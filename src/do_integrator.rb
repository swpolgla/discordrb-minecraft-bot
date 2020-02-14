require 'droplet_kit'


# This class provides a method to setup and return a DropletKit client.
class DO_INTEGRATOR
    
    # The default string in token_DO.txt when the user has not yet added their custom token
    TOKEN_NOT_FOUND = "token=INSERT DIGITALOCEAN API TOKEN HERE"
    
    token = TOKEN_NOT_FOUND
    
    # Initializes and returns a DropletKit client to access the DO api from.
    # @return nil if a valid API token cannot be found or hasn't been provided
    def initialize
        token = readToken
        
        if token == TOKEN_NOT_FOUND or token == nil
            return nil
        end
        
        token = token[6..token.length]
        
        return DropletKit::Client.new(access_token: token)
        
    end
    
    def readToken
        # Generates empty token/application ID files if they do not already exist
        if !File.exist?("token_do.txt")
            File.write("token_do.txt", TOKEN_NOT_FOUND)
            puts("A file has been created to store your DigitalOcean API token.")
            puts("This token can be found within your DigitalOcean account.")
            puts("Please insert it into token_do.txt before continuing")
        end

        # Reads your specific application ID/token from their individual files
        token = File.read("token_do.txt")
        if token == TOKEN_NOT_FOUND
            puts("Please insert your DigitalOcean API access token into token_do.txt before continuing.")
            puts("This token can be found within your DigitalOcean account.")
            return
        end
        return token
    end
end
