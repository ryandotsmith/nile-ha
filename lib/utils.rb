require 'scrolls'
Scrolls::Log.start

module FLock
  module Utils
    extend self

    def debug(data)
      log({level: "debug"}.merge(data))
    end

    def log(data)
      if block_given?
        Scrolls.log({:app => "f-lock"}.merge(data)) do
          yield
        end
      else
        Scrolls.log({:app => "f-lock"}.merge(data))
      end
    end

    def uri(host)
      ["http://", host, "/"].join
    end

    def ident(host)
      d_name(host).gsub(".","-")
    end

    def d_name(fqdn)
      fqdn.split(".")[1..-1].join(".") << "."
    end

    def c_name(fqdn)
      fqdn.split(".").first
    end
  end
end
