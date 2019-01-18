
sudo rm -rf _site

sudo rm -rf _cache

yui-compressor css/resume.css > css/resume.min.css

sudo stack build --allow-different-user
sudo stack exec blog build --allow-different-user
