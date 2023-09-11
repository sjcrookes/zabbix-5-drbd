# Zabbix 5 DRBD Templates & Scripts

Tested with Zabbix 5 and DRBD 8.x on Debian 8,9,10,11 - should work on pretty much any modern version of Linux, scripts require a recent-ish version of bash

Basically uses Zabbix auto discovery to find DRBD resources, and automatically add items, triggers and graphs to Zabbix.

The scripts are, a discovery script, which finds DRBD resources using ''/proc/drbd'', if there is a configuration available via ''drbdadm dump'' then it will use the name of the resouce, but the ''minor number'' will always be available. And a stats script, to pull detailed information from ''/proc/drbd''.


# Installation

Involves these 4 steps, 2 on the server and 2 on Zabbix, nothing strange, all standard usage:
* '''Server''' Copy scripts to /usr/local/bin/ and make them execuable
* '''Server''' Add custom user paramaters to Zabbix agent config, usually in /etc/zabbix/zabbix_agentd.d/
* '''Zabbix Server - Web Interface''' Import Value Mappings
* '''Zabbix Server - Web Interface''' Import Template

