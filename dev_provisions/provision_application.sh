source /vagrant/dev_provisions/environment.sh

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
echo progress-bar >> ~/.curlrc
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm install "ruby-2.6.6"
gem install fakes3 --no-document
gem install bundler:2.2.32 --no-document
cd /vagrant
bundle install
echo '##  Running rake commands...'
for env in development;
do
    for rake_step in create structure:load seed;
    do
        echo "## DATABASE_URL=postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost/blackops_${env} rake db:${rake_step}"
        cd /vagrant && DATABASE_URL=postgres://blackops:${BLACKOPS_DATABASE_PASSWORD}@localhost/blackops_${env} rake db:${rake_step} 2>&1 >> ${INSTALL_LOG};
    done
done

