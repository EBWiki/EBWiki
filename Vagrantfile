# frozen_string_literal: true

VAGRANTFILE_API_VERSION = '2'

guest_ip = '192.168.68.68'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-18.04'

  config.vm.define 'ebwiki-server' do |host|
    host.vm.hostname = 'ebwiki-server.local'
    host.vm.provision 'shell',
        name: 'sys',
        path: 'dev_provisions/provision_system.sh'
    host.vm.provision 'shell',
        name: 'app',
        path: 'dev_provision/provision_application.sh',
        privileged: false
    host.vm.network 'private_network', ip: "#{guest_ip}"
    host.vm.network 'forwarded_port', guest: '80', host: '3000'

    host.vm.provider 'virtualbox' do |v|
      v.memory = '1024'
      v.cpus = '1'
      v.name = 'EBWiki Server'
    end
  end
end

puts '-------------------------------------------------'
puts " Project URL : http://#{guest_ip}"
puts '-------------------------------------------------'
