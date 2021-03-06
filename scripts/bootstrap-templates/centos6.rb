<%#encoding: UTF-8%>
bash -c '

# ADD EPEL & RBEL REPOS
# ======================
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-7.noarch.rpm

rpm -Uvh http://rbel.co/rbel6
# END REPOS
# ======================


if [ ! -f /usr/bin/chef-client ]; then

  yum -y install gcc gcc-c++ kernel-devel make wget libxslt-devel libxml2-devel git autoconf flex bison openssl-devel libcurl-devel readline-devel kernel-headers zlib-devel ruby ruby-devel ruby-libs ruby-irb ruby-rdoc ruby-ri unzip rubygems ntp
  
fi

#### CLOCK SYNC #####
ntpdate pool.ntp.org
chkconfig ntpd on
service ntpd start

#### Installing chef ####
gem update --system
gem install ohai --no-rdoc --no-ri --verbose
gem install chef --no-rdoc --no-ri --verbose <%= bootstrap_version_string %>

#### Create OpenLMIS User ####
useradd openlmis -c "For eLMIS Application"

#### Remove tty from sudoers defaults ####
echo "openlmis        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers

#### Chef Setup ####
mkdir -p /etc/chef

(
cat <<'EOP'
<%= validation_key %>
EOP
) > /tmp/validation.pem
awk NF /tmp/validation.pem > /etc/chef/validation.pem
rm /tmp/validation.pem

(
cat <<'EOP'
log_level        :info
log_location     STDOUT
chef_server_url  "http://192.168.34.5:4000"
validation_client_name "chef-validator"
EOP
) > /etc/chef/client.rb

(
cat <<'EOP'
<%= { "run_list" => @run_list }.to_json %>
EOP
) > /etc/chef/first-boot.json

<%= start_chef %>'
