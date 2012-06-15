# f-lock

Much like a wild river, internet services will fail in catastrophic ways
during unexpected times. Rivers like the Mississippi employ a variety of methods
to protect against catastrophy --one of these methods involves building locks
to quickly redirect the flow of water to another channel. F-lock is a locking
mechanism to quickly shut off flow into a failed service and redirect the flow
into a standby service.

## Arch

F-lock requires a couple of moving parts --sigh.

* Amazon's Route53
* Apex domain access
* 2 or more independent platforms
* Your application
* Desire for availability

### Topology

![img](http://f.cl.ly/items/0a2v0F2a2y0E442X123e/arch.png)

## Usage

```bash
$ export AWS_ACCESS=key
$ export AWS_SECRET=secret
$ export AWS_API_V=2012-02-29
$ export CLOUD=primary
$ bin/f-lock ha.com. app
```
