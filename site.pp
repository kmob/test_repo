### site.pp - classify all nodes
node default {
#  include profile::base
}

node 'pm.example.com' {
  include role::puppet_master
}

node /^webserver_(\d+).example.com/ {
  #node 'webserver_01.example.com' {
  include role::example_website
}
