drop table if exists zones;
create table zones(id serial, fqdn text);

drop table if exists endpoints;
create table endpoints(id serial, zone_id int, host text);

insert into zones(fqdn) values('service.shushud-ha.net.');

insert into endpoints(zone_id, host) values(
       1, 'shushu.herokuapp.com');

insert into endpoints(zone_id, host) values(
       1, 'shushud.heroku-shadowapp.com');
