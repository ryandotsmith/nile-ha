require './lib/http'
require './lib/utils'
require './lib/dns'
require './lib/db'

module FLock
  module Monitor
    extend self
    def exec(endpoint)
      if HTTP.down?(endpoint["fqdn"], endpoint["host"])
        Utils.log(fn: __method__, at: "endpoint-down")
        DB.try_lock(:endpoint, endpoint["zone_id"]) do
          if !DNS.empty?(endpoint["fqdn"])
            DNS.delete(endpoint["fqdn"], endpoint["host"])
          else
            Utils.log(fn: __method__, at: "cant-kill", msg: "last-one")
          end
        end
        DB.check_fail(endpoint["id"])
      else
        Utils.log(fn: __method__, at: "endpoint-up")
        DB.try_lock(:endpoint, endpoint["zone_id"]) do
          if !DNS.include?(endpoint["fqdn"], endpoint["host"])
            DNS.create(endpoint["fqdn"], endpoint["host"])
          end
        end
        DB.check_pass(endpoint["id"])
      end
    end
  end
end
