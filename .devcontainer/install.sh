#! /bin/bash

sudo add-apt-repository -y ppa:mozillateam/ppa

echo -e "Package: firefox*\nPin: release o=LP-PPA-mozillateam-ppa\nPin-Priority: 550\n\nPackage: firefox*\nPin: release o=Ubuntu\nPin-Priority: -1" | sudo tee /etc/apt/preferences.d/99-mozillateamppa

cp script/sample_hooks/pre-commit/ .git/hooks/

sudo apt-get update

sudo apt install -y libvips
sudo apt install -y libpq-dev # Not strictly needed, but easier than explaining to users to constantly pass DB=sqlite
sudo apt install -y firefox 
sudo apt install -y codespell

echo 'CREATE DATABASE ffcrm_merge_development' | psql -U postgres
echo 'CREATE DATABASE ffcrm_merge_test' | psql -U postgres

bundle
bin/rails db:migrate