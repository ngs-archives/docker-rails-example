#!/bin/sh
set -eu

HASH=$(openssl rand -hex 4)

docker run \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  --name "dbmigrate-${HASH}" \
  -w /var/www/app -t $TARGET \
  sh -c './bin/rake db:create; ./bin/rake db:migrate:reset'

docker run \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --name "serverspec-${HASH}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'service supervisor start && bundle install --path=vendor/bundle && sleep 10 && bundle exec rake spec'

set +eu
[ $CI ] || docker rm "dbmigrate-${HASH}"
[ $CI ] || docker rm "serverspec-${HASH}"
