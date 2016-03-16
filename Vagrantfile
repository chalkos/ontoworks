# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end

$prov_script = <<SCRIPT
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8

sudo apt-get update
sudo apt-get install -y \
  autoconf \
  automake \
  bison \
  build-essential \
  curl \
  git \
  git-core \
  openjdk-7-jdk \
  libc6-dev \
  libcurl4-openssl-dev \
  libffi-dev \
  libgdbm-dev \
  libgmp-dev \
  libncurses5-dev \
  libpq-dev \
  libqt4-core \
  libqt4-dev \
  libqt4-gui \
  libreadline-dev \
  libreadline6 \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libtool \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  ncurses-dev \
  openssl \
  python-software-properties \
  qt4-dev-tools \
  sqlite3 \
  unzip \
  zlib1g \
  zlib1g-dev \

# rvm and ruby
su - vagrant -c 'echo "gem: --no-ri --no-rdoc" > ~/.gemrc'
echo "###############################################################"
echo "escrito ~/.gemrc"
echo "###############################################################"

su - vagrant -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'
echo "###############################################################"
echo "obtida chave pública do RVM"
echo "###############################################################"

su - vagrant -c 'curl -sSL https://get.rvm.io | bash -s stable'
echo "###############################################################"
echo "RVM instalado com ruby"
echo "###############################################################"

su - vagrant -c 'source ~/.rvm/scripts/rvm'
echo "###############################################################"
echo "RVM carregado para a sessão atual"
echo "###############################################################"

su - vagrant -c 'rvm install jruby-1.7.16'
echo "###############################################################"
echo "Instalado JRuby 1.7.16"
echo "###############################################################"

su - vagrant -c 'rvm alias create default jruby-1.7.16'
echo "###############################################################"
echo "JRuby 1.7.16 predefinido"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'gem install bundler --version 1.7.3'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Bundler 1.7.3 instalado"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'gem install rails --version 4.2.0'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Rails 4.2.0 instalado"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'gem install puma --version 2.11.1'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Puma 2.11.1 instalado"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'gem install rake --version 10.4.2'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Rake 10.4.2 instalado"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'gem install builder --version 3.2.2'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Rake 10.4.2 instalado"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'cd /home/vagrant/; git clone https://github.com/chalkos/ontoworks.git'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Checked out repository"
echo "###############################################################"

egrep --color 'Mem|Cache|Swap' /proc/meminfo
su - vagrant -c 'cd /home/vagrant/ontoworks; bundle install'
egrep --color 'Mem|Cache|Swap' /proc/meminfo
echo "###############################################################"
echo "Intalled remaining gems"
echo "###############################################################"

su - vagrant -c 'echo "export RAILS_ENV=production" >> ~/.profile'
echo "###############################################################"
echo "Default Rails environment set to production"
echo "###############################################################"

su - vagrant -c 'cd /home/vagrant/ontoworks; echo "export SECRET_KEY_BASE=$(rake secret)" >> ~/.profile'
echo "###############################################################"
echo "Created webserver secret and set it to environment variable SECRET_KEY_BASE"
echo "###############################################################"

su - vagrant -c 'cd /home/vagrant/ontoworks; rake db:drop db:create db:migrate assets:clean assets:precompile'
echo "###############################################################"
echo "Iniciada base de dados e pre-compilados assets "
echo "###############################################################"

echo "A script de instalação das ferramentas terminou!

## Instruções:

Próximos passos:
  1. usar o comando 'vagrant reload' reiniciar a máquina virtual
  2. usar o comando 'vagrant up' para iniciar a máquina virtual
  3. usar o comando 'vagrant ssh' para entrar na máquina virtual
  4. executar a script em '/home/vagrant/ontoworks/railsStart'

Para desligar:
  1. terminar o comando que está a correr (CTRL+C)
  2. sair da máquina virtual (CTRL+D)
  3. usar o comando 'vagrant halt'

Para ligar da próxima vez:
  1. usar o comando 'vagrant up' para iniciar a máquina virtual
  2. usar o comando 'vagrant ssh' para entrar na máquina virtual
  3. executar a script em '/home/vagrant/ontoworks/railsStart'

## Não funcionou?
Se ocorreu algum problema causado por falha de internet, executar os seguintes comandos para recomeçar:
vagrant destroy
vagrant up"
SCRIPT

  config.vm.provision "shell", inline: $prov_script
end
