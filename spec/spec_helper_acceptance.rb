require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'pry'

unless ENV['BEAKER_provision'] == 'no'
  if default.is_pe?
    install_pe
  else
    if ENV['USE_PUPPET_AGENT']
      install_options = {}
      install_options[:version] = ENV['PUPPET_AGENT_VERSION'] if ENV['PUPPET_AGENT_VERSION']

      install_puppet_agent(install_options)
    else
      install_options                  = {:default_action => 'gem_install'}
      install_options[:version]        = ENV['PUPPET_VERSION'] if ENV['PUPPET_VERSION']
      install_options[:facter_version] = ENV['FACTER_VERSION'] if ENV['FACTER_VERSION']
      install_options[:hiera_version]  = ENV['HIERA_VERSION']  if ENV['HIERA_VERSION']

      install_puppet(install_options)
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    install_options = { :source      => proj_root,
                        :module_name => 'docker'   }

    install_options[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']

    puppet_module_install(install_options)
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt', '--version', '1.8.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'stahnma-epel'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
