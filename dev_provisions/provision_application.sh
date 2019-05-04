gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
echo progress-bar >> ~/.curlrc
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm install "ruby-2.5.5"
gem install fakes3 --no-document
gem install bundler:1.17.3 --no-documentation
cd /vagrant
bundle install
