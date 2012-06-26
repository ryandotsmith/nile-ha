require './lib/utils'
require 'rest-client'
require 'timeout'

module FLock
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
