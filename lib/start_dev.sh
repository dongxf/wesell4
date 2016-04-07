#only works under iMac development

pid=`ps -ef | grep unicorn | grep -v grep | awk '{print $2}'`
if [ -n "$pid" ]; then
  echo "kill unicorn $pid"
  kill $pid
fi

pid=`ps -ef | grep sidekiq | grep -v grep | awk '{print $2}'`
if [ -n "$pid" ]; then
  echo "kill sidekiq $pid"
  kill $pid
fi

pid=`ps -ef | grep solr | grep java | grep -v grep | awk '{print $2}'`
if [ -n "$pid" ]; then
  echo "kill solr $pid"
  kill $pid
fi

pid=`ps -ef | grep redis-server | grep -v grep | awk '{print $2}'`
if [ -z "$pid" ]; then
  echo "start redis"
  /usr/local/opt/redis/bin/redis-server /usr/local/etc/redis.conf
else
  echo "redis already run: $pid"
fi

cd ~/wesell4
bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml
rake sunspot:solr:start
unicorn -D
#cd ~/wesell4/log
#tail -f *.log
