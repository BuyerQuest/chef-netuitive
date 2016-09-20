require 'spec_helper'

describe 'netuitive::add_repo' do
  if %w(debian ubuntu).include?(os[:family])
    content = [
      'deb     "https://repos.app.netuitive.com/deb/"  stable main'
    ].join("\n") << "\n"
    repo_file = '/etc/apt/sources.list.d/netuitive.list'
  elsif %w(redhat fedora).include?(os[:family])
    content = [
      '# This file was generated by Chef',
      '# Do NOT modify this file by hand.',
      '',
      '[netuitive]',
      'name=Netuitive EPEL Repo',
      'baseurl=https://repos.app.netuitive.com/rpm/$basearch/',
      'enabled=1',
      'gpgcheck=1',
      'gpgkey=https://repos.app.netuitive.com/RPM-GPG-KEY-netuitive',
      'priority=10'
    ].join("\n") << "\n"
    repo_file = '/etc/yum.repos.d/netuitive.repo'
  else
    print "I dont have unit tests for os: #{os[:family]}"
  end

  describe file(repo_file) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should eq content }
  end
end

describe 'netuitive::install_agent' do
  describe package('netuitive-agent') do
    it { should be_installed }
  end

  describe file('/opt/netuitive-agent') do
    it { should be_directory }
  end
end

describe 'netuitive::configure' do
  describe file('/opt/netuitive-agent/conf/netuitive-agent.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/api_key = CHANGE_ME_PLZ/) }
  end

  describe file('/opt/netuitive-agent/conf/collectors/FooBarCollector.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(/foo = bar/) }
  end

  describe service('netuitive-agent') do
    it { should be_enabled }
    it { should be_running }
  end
end