#! /bin/bash

sudo apt-get update

sudo apt install -y libvips
sudo apt install -y libpq-dev # Not strictly needed, but easier than explaining to users to constantly pass DB=sqlite
sudo apt install -y codespell

echo 'CREATE DATABASE ffcrm_merge_development' | psql -U postgres
echo 'CREATE DATABASE ffcrm_merge_test' | psql -U postgres

bundle
bin/rails db:migrate