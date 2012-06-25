require 'bundler/setup'
require 'sinatra'
require 'json'
require './lib/utils'
require './lib/dns'
require './lib/db'

module FLock
  module Service
    extend self

    def zone_details(zid)
      r = DB.zone_endpoints(zid).reduce({}) do |ini, ep|
        ini["zone_id"] ||= ep["zone_id"]
        ini["fqdn"] ||= ep["fqdn"]
        ini["ns"] = DNS.name_servers(ep["fqdn"])
        ini["hosts"] ||= []
        ini["hosts"] << ep["host"]
        ini
      end
      r.length.zero? ? nil : r
    end

    def setup_zone(fqdn)
      Utils.log(fn: __method__) do
        DB.transaction do
          DNS.create_zone(fqdn)
          DB.create_zone(fqdn)
        end
      end
    end

    def reset_endpoints(zid, host1, host2)
      Utils.log(ns: "nile-service", fn: __method__, zid: zid) do
        DB.delete_endpoints(zid)
        host1 && DB.create_endpoint(zid, host1)
        host2 && DB.create_endpoint(zid, host2)
      end
    end

    def put_zone(fqdn)
      DB.find_zone(fqdn) || setup_zone(fqdn)
    end

  end
end

use Rack::MethodOverride

set :public_folder, "./nile/public"
set :views, "./nile/templates"

get "/" do
  erb :index
end

get "/zones" do
  content_type(:json)
  status(200)
  body(JSON.dump(FLock::DB.all_zones))
end

get "/zones/:id" do |id|
  content_type(:json)
  body(JSON.dump(FLock::Service.zone_details(id)))
end

put "/zones/:fqdn" do |fqdn|
  content_type(:json)
  zone = FLock::Service.put_zone(fqdn)
  FLock::Service.reset_endpoints(zone["id"], params[:host1], params[:host2])
  body(JSON.dump(FLock::Service.zone_details(zone["id"])))
end