# Nile-ha

Much like the whims of a wild river, unexpected events can cause internet services to fail in catastrophic ways. Civil engineers tame rivers, like the Mississippi, by employing a variety of methods to protect against catastrophe -- one of these methods involves building locks to quickly redirect the flow of water to another channel. Similarly, in the event of an internet service catastrophy, nile-ha will block flow into the failed service.

## Arch

Nile-ha requires a few dependencies:

* Amazon's Route53
* Apex domain access
* N independent platforms
* Desire for availability

### Topology

![img](http://f.cl.ly/items/1e1y3O3K39391k360h0p/arch%20copy.png)

## Deploy to Heroku

```bash
$ git clone https://github.com/ryandotsmith/nile-ha.git
$ cd nile-ha
$ heroku create
$ heroku config:add $(cat sample.env)
$ heroku scale gc=1 monitor=1 web=1
```
