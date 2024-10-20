## Adguard Home + unbound + redis

[Adguard Home](https://github.com/AdguardTeam/AdGuardHome) uses [unbound](https://unbound.docs.nlnetlabs.nl/en/latest/) as upstream DNS server with prefetch turned on. Unbound uses [redis-server](https://redis.io/docs/latest/get-started/) as in-memory data cache.


### Why
---

When you enable prefetching in Unbound, it pre-emptively resolves and caches DNS queries before they are actually requested by clients. This can significantly speed up DNS resolution times because the answers are already in the cache when needed.

#### **Advantages of Unbound with prefetching:**

1.  **Faster DNS Resolution**: By having frequently accessed DNS records pre-fetched and cached, the response time for these queries is reduced.
2.  **Reduced Latency**: Prefetching minimizes the delay caused by DNS lookups, which is especially beneficial for applications requiring quick access to DNS records.
3.  **Improved Performance**: Overall, prefetching can enhance the performance of your network by ensuring that DNS responses are readily available

#### Advantage of redis-server:

1.  **Reduced Latency**: Redis is an in-memory data store, which means it can serve DNS query results much faster than disk-based caching systems1. This can significantly reduce the latency of DNS queries.
2.  **Improved Performance**: By caching DNS query results in Redis, Unbound can handle queries more efficiently, leading to improved overall performance.
3.  **Reduced Load on Upstream DNS Servers**: With Redis caching frequently accessed DNS records, the number of queries sent to upstream DNS servers is reduced, which can help in lowering the load on these servers.
4.  **Enhanced Reliability**: Redis can provide a reliable caching layer, ensuring that DNS query results are quickly accessible even during high traffic periods  
      
     

### Usage
---

This docker was created for unraid.  
You must use this docker with a dedicated IP or network, because the port 53 is used already used by unraid/docker by default.

The default credentials for Adguard Home: admin/admin  
The default port for the Adguard Home WebGUI: 3000  
(You can change both in the config/AdGuardHome/AdGuardHome.yaml)

By default, configuration files are located in /mnt/user/appdata/adguard-unbound-redis/ in the following sub-directories:  
 
<table><tbody><tr><td>/redis</td><td>config files for redis</td></tr><tr><td>/AdGuardHome</td><td>config file for ADGH</td></tr><tr><td>/unbound</td><td>config file for unbound</td></tr><tr><td>/data</td><td>working folder for ADGH</td></tr></tbody></table>

unbound is configured to forward all requests to public dns. By default, Coudflare DNS are selected.
You can change this in `forward-queries.conf` . Other servers are pre-defined in this file, and you can add others.
If you want it to do the resolution itself (recursive), simply delete the file.
