require 'route53'

module FLock
  module DNS
    extend self

    def create_zone(fqdn)
      d_name = Utils.d_name(fqdn)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name) do
        resp = Route53::Zone.
          new(d_name, nil, conn).
          create_zone
        while resp.pending?
          sleep(0.5)
        end
      end
    end

    def empty?(fqdn)
      d_name = Utils.d_name(fqdn)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name)
      c_names(d_name).empty?
    end

    def include?(fqdn, host)
      d_name = Utils.d_name(fqdn)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name, host: host)
      c_names(d_name).any? {|e| e.values.include?(host)}
    end

    def create(fqdn, host)
      d_name, ident = Utils.d_name(fqdn), Utils.ident(host)
      Utils.log(ns: "dns", fn: __method__, fqdn: fqdn, ident: ident) do
        ttl = "10"
        Route53::DNSRecord.
          new(fqdn,"CNAME", ttl, [host], zone(d_name), nil, 1, ident).
          create
      end
    end

    def delete(fqdn, host)
      d_name = Utils.d_name(fqdn)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name, host: host) do
        c_names(d_name).select do |e|
          e.values.include?(host)
        end.map {|r| r.delete}
      end
    end

    def name_servers(fqdn)
      d_name = Utils.d_name(fqdn)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name) do
        zone(d_name).get_records.find {|r| r.type == "NS"}.values
      end
    end

    def c_names(d_name)
      Utils.log(ns: "dns", fn: __method__, d_name: d_name) do
        zone(d_name).get_records.select {|r| r.type == "CNAME"}
      end
    end

    def zone(d_name)
      conn.get_zones.find {|z| z.name == d_name}.tap do |z|
        raise "Unable to find zone=#{d_name}" unless z
      end
    end

    def conn
      @conn ||= Route53::Connection.
        new(ENV["AWS_ACCESS"], ENV["AWS_SECRET"], ENV["AWS_API_V"])
    end

  end
end
