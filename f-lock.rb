require 'bundler/setup'
require 'ruby-debug'
require 'rest-client'

require './lib/utils'
require './lib/db'
require './lib/dns'

$running = true

module FLock
  module Monitor
    extend self
    def run(endpoint)
      while($running)
        if HTTP.down?(endpoint["host"])
          Utils.log(fn: __method__, at: "endpoint-down")
          DB.lock_zone(endpoint["zone_id"]) do
            if !DNS.empty?(endpoint["fqdn"])
              DNS.delete(endpoint["fqdn"], endpoint["host"])
            else
              Utils.log(fn: __method__, at: "cant-kill", msg: "last-one")
            end
          end
        else
          Utils.log(fn: __method__, at: "endpoint-up")
          DB.lock_zone(endpoint["zone_id"]) do
            if !DNS.include?(endpoint["fqdn"], endpoint["host"])
              DNS.create(endpoint["fqdn"], endpoint["host"])
            end
          end
        end
      end
    end
  end

  module HTTP
    extend self
    def down?(host)
      uri = Utils.uri(host)
      Utils.log(ns: "http", fn: __method__, uri: uri) do
        begin
          Timeout::timeout(2) {RestClient.head(uri)}
          false
        rescue
          true
        end
      end
    end
  end

end
