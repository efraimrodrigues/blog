
sudo rm -rf _site

sudo rm -rf _cache

sudo stack build --allow-different-user
sudo stack exec blog build --allow-different-user
