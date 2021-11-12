# vas

A simple vagrant ansible shell package

# Host Recmmended Requirements:

- [Vagrant](https://www.vagrantup.com/) - Development Environments Made Easy

- [Vai](https://github.com/cjsteel/vagrant-plugin-vai) - A Vagrant provisioning plugin to output a usable ]Ansible inventory to use outside Vagrant.

- [vbguest](https://github.com/dotless-de/vagrant-vbguest) -  A Vagrant plugin to keep your VirtualBox Guest Additions up to date

- [vagrant-aws](https://github.com/mitchellh/vagrant-aws) - Use Vagrant to manage your EC2 and VPC instances.

# Clean for your own use

```sh
wget -O - https://raw.githubusercontent.com/kedwards/vas/master/install.sh | sudo bash -s <project-name> <sudo_password>
```

or

```sh
git clone --depth=1 git@github.com:kedwards/vas.git && \
rm -rf vas/.git\* && \
mv vas <project-name>
```

# Test

```
cd vagrant
vagrant up
```