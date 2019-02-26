# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

plugins_dependencies = %w(vagrant-aws vagrant-vbguest vagrant-hostsupdater vai)
plugin_status = false
plugins_dependencies.each do |plugin_name|
    unless Vagrant.has_plugin? plugin_name
        system("vagrant plugin install #{plugin_name}")
        plugin_status = true
        puts " #{plugin_name}  Dependencies installed"
    end
end
if plugin_status === true
    exec "vagrant #{ARGV.join" "}"
end

machines = YAML.load_file(File.join(File.dirname(__FILE__), 'machines.yml'))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    machines.each_with_index do |machine, index|
        if machine['enabled'] == true
            config.vm.define machine['name'] do |srv|
                srv.vm.hostname = machine['name']
                srv.vm.synced_folder '.', '/vagrant', disabled: machine['sync']

                srv.vm.provision :vai do |ansible|
                  ansible.inventory_dir='inventory/'
                  ansible.inventory_filename='vagrant'
                end
                
                case machine['type']
                when 'vb'
                    srv.vbguest.auto_update = machine['guest_update']
                    srv.vm.box_check_update = machine['update_box']
                    srv.vm.network :private_network, ip: machine['ip_addr']
                    srv.vm.provider :virtualbox do |vb, override|
                        override.vm.box = machine['box']
                        vb.memory = machine['ram']
                        vb.cpus = machine['vcpu']
                        vb.customize [
                            "modifyvm", :id,
                            "--nictype1", "virtio",
                            "--natdnshostresolver1", "on",
                        ]
                    end

                when 'aws'
                    srv.vm.provider :aws do |aws, override|
                        override.vm.box = machine['box']
                        override.ssh.username = "admin"
                        override.ssh.private_key_path = machine['private_key_path']
                        aws.aws_dir = ENV['HOME'] + "/.aws/"
                        aws.ami = machine['ami']
                        aws.session_token = ENV['SESSION TOKEN']
                        aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
                        aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
                        aws.region = ENV['AWS_DEFAULT_REGION']
                        aws.keypair_name = machine['keypair_name']
                        aws.instance_type = machine['instance_type']
                        aws.subnet_id = machine['subnet_id']
                        aws.security_groups = machine['security_group']
                        aws.associate_public_ip = machine['associate_public_ip']
                        aws.tenancy = "default"
                        aws.tags = {
                          'Name' => machine['tags']['name'],
                          'Team' => machine['tags']['team']
                        }
                    end
                end
            end
        end
    end
end
