#!/bin/sh
set -eu

HASH=$(openssl rand -hex 4)
DATABASE_URL=mysql2://root:dev@dev-mysql/docker-rails-example

docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  --name "dbmigrate-${HASH}" \
  -w /var/www/app -t $TARGET \
  sh -c './bin/rake db:create; ./bin/rake db:migrate:reset'

docker run \
  -e DATABASE_URL="${DATABASE_URL}" \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --name "serverspec-${HASH}" \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/app/.env && service supervisor start && bundle install --path=vendor/bundle && sleep 1 && bundle exec rake spec'

set +eu
[ $CI ] || docker rm "dbmigrate-${HASH}"
[ $CI ] || docker rm "serverspec-${HASH}"
