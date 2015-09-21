require 'spec_helper'

describe_recipe 'CollectdWin-cookbook::windows_performance_counter' do
  context 'with default attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
      end.converge(described_recipe)
    end

    it do
      expect(chef_run).to create_collectdwin_config('WindowsPerformanceCounter.config')
        .with(cfg_name: 'windows_performance_counter')
    end
    it { chef_run }
  end
end