2 providers on the same gateway load balancing* and failover
Create script which will ping every 5 second popular resources on the Internet
/usr/local/bin/eq-route.sh

Make it executable: chmod +x /usr/local/bin/eq-route.sh

Create daemon: /etc/systemd/system/eqroute-failover.service
Add autostart: systemctl enable eqroute-failover.service
Start daemon: systemctl start eqroute-failover.service

*Note that balancing will not be perfect, as it is route based, and routes are cached. This means that routes to often-used sites will always be over the same provider.
