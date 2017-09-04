2 providers on the same gateway load balancing and failover

Создаем демон 
/etc/systemd/system/eqroute-failover.service

Создаем скрипт который будет пинговать каждые 5 секунд популярные ресурсы в интернете и в случае недоступности этих ресурсов переключать на одного из провайдеров и также проводить балансировку

/usr/local/bin/eq-route.sh
Не забываем сделать файл исполняемым  chmod +x /usr/local/bin/eq-route.sh

Добавляем в автозагрузку

systemctl enable eqroute-failover.service

Стартуем сервис

systemctl start eqroute-failover.service
