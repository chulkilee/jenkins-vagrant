VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'hashicorp/precise64'

  # plugin: vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  # https://github.com/smdahlen/vagrant-hostmanager/issues/86
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    if hostname = (vm.ssh_info && vm.ssh_info[:host])
      `vagrant ssh -c "/sbin/ifconfig eth1" | grep "inet addr" | tail -n 1 | egrep -o "[0-9\.]+" | head -n 1 2>&1`.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
    end
  end

  config.vm.define :master, primary: true do |master|
    # configure network
    master.vm.hostname = 'jenkins.vm'
    master.vm.network :private_network, type: :dhcp

    master.vm.provider 'virtualbox' do |v|
      v.name = 'jenkins-master'
      v.customize ['modifyvm', :id, '--memory', 1024]
    end

    master.vm.provision :hostmanager
    %w(base jenkins mysql nodejs).each do |name|
      master.vm.provision 'shell', path: "scripts/#{name}.sh"
    end
  end
end
