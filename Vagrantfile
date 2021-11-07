VAGRANTFILE_API_VERSION = "2"
VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))
require 'yaml'

# https://github.com/mitchellh/vagrant-aws/issues/566#issuecomment-580812210
class Hash
  def slice(*keep_keys)
    h = {}
    keep_keys.each { |key| h[key] = fetch(key) if has_key?(key) }
    h
  end unless Hash.method_defined?(:slice)
  def except(*less_keys)
    slice(*keys - less_keys)
  end unless Hash.method_defined?(:except)
end

# load configs
config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
ansible_var_file = File.join(File.dirname(__FILE__), 'ansible/ansible_vars.yml')
if File.exist?(ansible_var_file)
  ansible_extra_vars = YAML.load_file(ansible_var_file)
end

plugin_status = false
config['plugins'].each do |plugin_name|
  unless Vagrant.has_plugin? plugin_name
    system("vagrant plugin install #{plugin_name}")
    plugin_status = true
    puts " #{plugin_name} Dependencies installed"
  end
end
if plugin_status === true
  exec "vagrant #{ARGV.join" "}"
end

cfg = config[config['use']]
if cfg.nil?
  puts "No configuration found for #{config['use']}"
  exit 1
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  cfg.each do |grp|
    num_nodes = grp['nodes']
    (1..num_nodes).each do |i|
      vm_name = "%s%02d" % [grp['name_prefix'], i]
      config.vm.define vm_name do |srv|
        srv.vm.hostname = vm_name

        if not grp['provisioner'].nil?
          grp['provisioner'].each do |p|
            case p['type']
            when 'ansible'
              srv.vm.provision p['type'] do |a|
                a.playbook = p['playbook']
                a.config_file = p['config_file']
                a.verbose = true
                a.extra_vars = ansible_extra_vars
                a.ask_become_pass = p['ask_become_pass']

                if not p.inventory_path.empty?
                  a.inventory_path = p['inventory_path']
                end

                # a.groups = {
                #   "managers" => ["manager01"],
                #   "workers" => ["workers[01:02]"],
                #   "all_groups:children" => ["managers", "workers"]
                # }
              end

            when 'shell'
              srv.vm.provision p['type'], inline: p['script'], privileged: true
            end
          end
        end

        guest_ipaddr = grp['ip_addr'].to_s + (i + 1).to_s
        srv.vm.provision :shell, inline: "echo #{guest_ipaddr} #{vm_name} >>  /etc/hosts", privileged: true

        case grp['type']
        when 'docker'
          srv.vm.provider "docker" do |d|
            d.image = grp['image']
            if not grp['ports'].nil?
              host_port = grp['ports']['host'].to_i + i
              d.ports = ["#{host_port}:#{grp['ports']['guest']}"]
            end
          end

        when 'vb'
          srv.vm.network "private_network", ip: guest_ipaddr, netmask: grp['netmask']
          srv.vm.synced_folder '.', '/vagrant', disabled: grp['synced_folder_disabled']
          srv.vm.box_check_update = grp['box_check_update']
          srv.ssh.forward_agent = true

          srv.vm.provider :virtualbox do |vb, override|
            override.vm.box = grp['box']
            vb.check_guest_additions = grp['check_guest_additions']
            vb.name = vm_name
            vb.memory = grp['ram']
            vb.cpus = grp['vcpu']
            vb.customize [
              "modifyvm", :id,
              "--uartmode1", "disconnected",
              "--nictype1", "virtio",
              "--natdnshostresolver1", "on"
            ]

            disks = grp['disks'].to_i
            disk_size = grp['disk_size'].to_i

            (1..disks).each do |k|
              more_disk = File.join(VAGRANT_ROOT, "DATA/#{vm_name}_disk#{k}.vdi")
              unless File.exist?(more_disk)
                vb.customize ['createhd', '--filename', more_disk, '--size', disk_size * 1024]
              end
              vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', k+1, '--device', 0 , '--type', 'hdd', '--medium', more_disk]
            end

            if not grp['usb'].nil?
              grp['usb'].each do |usb, index|
                vb.customize ["modifyvm", :id, "--usb", "on"]
                vb.customize ['usbfilter', 'add', '#{index}', '--target', :id, '--name', '#{usb.name}', '--vendorid', '#{usb.vendorid}', '--productid', '#{usb.productid}']
              end
            end
          end

        when 'aws'
          srv.vm.provider :aws do |aws, override|
            override.vm.box = grp['box']
            aws.ami = grp['ami']
            override.ssh.username = grp['ssh_username']
            override.ssh.private_key_path = grp['private_key_path']
            aws.tenancy = "default"
            aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
            aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
            aws.session_token = ENV['AWS_SESSION_TOKEN']
            aws.instance_type = grp['instance_type']
            aws.region = grp['region']
            aws.keypair_name = grp['keypair_name']
            aws.subnet_id = grp['subnet_id']
            aws.security_groups = grp['security_group']
            aws.associate_public_ip = grp['associate_public_ip']
            aws.tags = {
              'Name' => vm_name,
              'Team' => grp['tags']['team']
            }
          end
        end
      end
    end
  end
end