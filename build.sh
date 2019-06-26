
sudo rm -rf _site

sudo rm -rf _cache

yui-compressor css/resume.css > css/resume.min.css
yui-compressor js/resume.js > js/resume.min.js
stack setup

sudo stack build --allow-different-user
sudo stack exec blog build --allow-different-user