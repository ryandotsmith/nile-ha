require 'pg'
require './lib/utils'

module FLock
  module DB
    extend self
    SPACES = {zone: 1, endpoint: 2}

    def health_check
      s = "select endpoint, max(time) from checks group by endpoint"
      conn.exec(s).to_a.map {|check| Time.parse(check["max"])}
    end

    def check_pass(eid)
      s = "insert into checks(endpoint, state, time) values ($1, 1, now())"
      conn.exec(s, [eid])
    end

    def check_fail(eid)
      s = "insert into checks(endpoint, state, time) values ($1, -1, now())"
      conn.exec(s, [eid])
    end

    def find_zone(fqdn)
      r = conn.exec("select * from zones where fqdn = $1", [fqdn])
      r.ntuples.zero? ? nil : r[0]
    end

    def create_zone(fqdn)
      conn.exec("insert into zones(fqdn) values ($1) returning *", [fqdn])[0]
    end

    def delete_endpoints(zid)
      conn.exec("delete from endpoints where zone_id = $1", [zid])
    end

    def create_endpoint(zid, host)
      Utils.log(ns: "db", fn: __method__, zid: zid, host: host) do
        conn.exec("insert into endpoints(zone_id, host) values($1, $2)",
                 [zid, host])
      end
    end

    def all_zones
      conn.exec("select id, fqdn from zones").to_a
    end

    def zone_endpoints(zid)
      sql = "select "
      sql << "endpoints.id as id, endpoints.host as host, "
      sql << "zones.id as zone_id, zones.fqdn as fqdn "
      sql << "from endpoints, zones "
      sql << "where endpoints.zone_id = zones.id and zones.id = $1"
      conn.exec(sql, [zid]).to_a
    end

    def all_endpoints(clouds="herokuapp.com")
      sql = "select "
      sql << "endpoints.id as id, endpoints.host as host, "
      sql << "zones.id as zone_id, zones.fqdn as fqdn "
      sql << "from endpoints, zones "
      sql << "where endpoints.zone_id = zones.id "
      sql << "and ("
      clouds.to_enum.with_index(1).each do |cloud, i|
        sql << " endpoints.host like '%#{cloud}%' "
        sql << " OR " if i != clouds.length
      end
      sql << ")"
      conn.exec(sql).to_a
    end

    def try_lock(space, id)
      begin
        until lock(space, id)
          sleep(0.25)
        end
        yield if block_given?
      ensure
        unlock(space, id)
      end
    end

    def lock(space, pos)
      spid = SPACES[space]
      Utils.log(ns: "db", fn: __method__, space: space, spid: spid, pos: pos) do
        r = conn.exec("select pg_try_advisory_lock($1, $2)", [spid, pos])
        r[0]["pg_try_advisory_lock"] == "t"
      end
    end

    def unlock(space, pos)
      spid = SPACES[space]
      Utils.log(ns: "db", fn: __method__, space: space, spid: spid, pos: pos) do
        conn.exec("select pg_advisory_unlock($1, $2)", [spid, pos])
      end
    end

    def transaction
      res = nil
      conn.transaction {res=yield}
      res
    end

    def conn
      @con ||= PG::Connection.open(
        dburl.host,
        dburl.port || 5432,
        nil, '', #opts, tty
        dburl.path.gsub("/",""), # database name
        dburl.user,
        dburl.password
      )
    end

    def dburl
      URI.parse(ENV["DATABASE_URL"])
    end
  end
end
