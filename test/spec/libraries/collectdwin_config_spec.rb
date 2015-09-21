require 'chefspec'
require 'chefspec/berkshelf'
require 'poise_boiler/spec_helper'
require_relative '../../../libraries/collectdwin_config'

describe CollectdWinCookbook::Resource::CollectdWinConfig do
  cfg_dir_name = "#{ENV['ProgramW6432']}/CollectdWin/config"
  cfg_file_name = 'test.config'
  cfg_file = ::File.join(cfg_dir_name, cfg_file_name)
  step_into(:collectdwin_config)
  context '#snake_to_camel' do
    recipe do
      collectd_config cfg_file_name do
      cfg_name 'test_section'
      directory cfg_dir_name
        configuration(
          'load_plugin' => 'foo',
          'format' => 'bar',
          'j_s_o_n' => 'baz'
        )
      end

      it { expect(chef_run).to render_file(cfg_file).with_content(<<-EOH.chomp) }

<!-- Generated by collectdwin-cookbook -->

<TestSection>
  <LoadPlugin>foo</LoadPlugin>
  <Format>bar</Format>
  <JSON>baz</JSON>
</TestSection>
EOH
    end
  end

context '#write_elements' do
    recipe do
      collectdwin_config cfg_file_name do
        cfg_name 'test_section'
        directory cfg_dir_name
        configuration(
          'general_settings' => { 'attr' => { 'interval' => 30, 'timeout' => 120, 'store_rates' => false } },
          'plugins' => [ 
            { 'plugin' => { 'attr' => { 'name' => 'Statsd', 'class' => 'BloombergFLP.CollectdWin.StatsdPlugin', 'enable' => true } } }, 
            { 'plugin' => { 'attr' => { 'name' => 'WindowsPerformanceCounter', 'class' => 'BloombergFLP.CollectdWin.WindowsPerformanceCounterPlugin', 'enable' => true } } },
            { 'plugin' => { 'attr' => { 'name' => 'Amqp', 'class' => 'BloombergFLP.CollectdWin.AmqpPlugin', 'enable' => false } } },
            { 'plugin' => { 'attr' => { 'name' => 'WriteHttp', 'class' => 'BloombergFLP.CollectdWin.WriteHttpPlugin', 'enable' => false } } },
            { 'plugin' => { 'attr' => { 'name' => 'Console', 'class' => 'BloombergFLP.CollectdWin.ConsolePlugin', 'enable' => true } } }
          ]
        )
      end
    end

    it { expect(chef_run).to render_file(cfg_file).with_content(<<-EOH.chomp) }

<!-- Generated by collectdwin-cookbook -->

<TestSection>
  <GeneralSettings Interval="30" Timeout="120" StoreRates="false"/>
  <Plugins>
    <Plugin Name="Statsd" Class="BloombergFLP.CollectdWin.StatsdPlugin" Enable="true"/>
    <Plugin Name="WindowsPerformanceCounter" Class="BloombergFLP.CollectdWin.WindowsPerformanceCounterPlugin" Enable="true"/>
    <Plugin Name="Amqp" Class="BloombergFLP.CollectdWin.AmqpPlugin" Enable="false"/>
    <Plugin Name="WriteHttp" Class="BloombergFLP.CollectdWin.WriteHttpPlugin" Enable="false"/>
    <Plugin Name="Console" Class="BloombergFLP.CollectdWin.ConsolePlugin" Enable="true"/>
  </Plugins>
</TestSection>
EOH
  end
end