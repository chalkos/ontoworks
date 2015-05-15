name "web_server"
description "A role to configure the web server"

default_attributes(
  "java" => {
    "install_flavor" => "openjdk",
    "jdk_version" => "7"
  }
)

#default_attributes(
#  "rvm" => {
#    "installs" => {
#      "vagrant" => {
#        "default_ruby"  => "jruby-1.7.16",
#        "global_gems"   => [
#          {
#            "name" => "bundler",
#            "version" => "1.7.3"
#          },
#          {
#            "name" => "rake",
#            "version" => "10.4.2"
#          },
#          {
#            "name" => "rails",
#            "version" => "4.2.0"
#          }
#        ]
#      }
#    }
#  }
#)

run_list 'recipe[java]', 'recipe[rvm::user]'
