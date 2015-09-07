#!/bin/sh
set -eu

docker run --rm \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /var/www/app -t $TARGET \
  sh -c './bin/rake db:create; ./bin/rake db:migrate'

docker run --rm \
  -v "$(pwd)/docker/serverspec"\:/mnt/serverspec \
  --link dev-mysql:mysql \
  --link dev-redis:redis \
  -w /mnt/serverspec -t $TARGET \
  sh -c 'service supervisor start && bundle install --path=vendor/bundle && bundle exec rake spec'
