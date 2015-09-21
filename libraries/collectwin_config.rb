require 'poise'

module CollectdWinCookbook
  module Resource
    # A resource which manages CollectdWin service configurations.
    # @since 1.0.0
    # @example
    # collectdwin_config 'C:\Program Files\CollectdWin\config\CollectdWin.config' do
    #   configuration(
    #     'GeneralSettings' => {'Interval' => 30, 'Timeout' => 120, 'StoreRates' => false}
    #   )
    # end
    class CollectdWinConfig < Chef::Resource
      include Poise(fused: true)
      provides(:collectdwin_config)

      attribute(:file_name, kind_of: String, name_attribute: true)
      attribute(:cfg_name, kind_of: String)
      attribute(:directory, kind_of: String)
      attribute(:configuration, option_collector: true)

      # Produces collectd {configuration} elements from resource.
      # @return [String]
      def content
        hdr = "\n<!-- Generated by collectdwin-cookbook -->\n\n"
        hdr + write_elements("#{cfg_name}" => configuration).concat("\n")
      end

      # @return [String]
      def config_filename
        ::File.join(directory, "#{file_name}")
      end

      # Converts from snake case to a camel case string.
      # @param [String, Symbol] s
      # @return [String]
      def snake_to_camel(s)
        s.to_s.split('_').map(&:capitalize).join('')
      end

      # Writes out attributes from {directives}
      # @param [Hash] directives
      def write_attributes(directives)
        directives.dup.map do |key, value|
          key = snake_to_camel(key)
          %(#{key}="#{value}")
        end.join(' ')
      end

      # Recursively writes out configuration elements from
      # {directives} and applies the appropriate {indent}.
      # @param [Hash] directives
      # @param [Integer] indent
      # @return [String]
      def write_elements(directives, indent = 0)
        tabs = ("\t" * indent)
        directives.dup.map do |key, value|
          next if value.nil? || key == 'attr'
          key = snake_to_camel(key)
          if value.is_a?(Array)
            tmpstr = ''
            value.each do |val|
              tmpstr += write_elements(val, indent.next) + "\n"
            end
            [%(#{tabs}<#{key}>\n),
             tmpstr,
             %(#{tabs}</#{key}>)
            ].join('')
          elsif value.is_a?(Hash)
            attributes = value.fetch('attr', 0)
            if attributes.is_a?(Hash)
              attrstr = ' ' + write_attributes(attributes)
            end
            if value.length <= 0 || (value.length == 1 && value.key?('attr'))
              %(#{tabs}<#{key}#{attrstr}/>)
            else
              [%(#{tabs}<#{key}#{attrstr}>),
               write_elements(value, indent.next),
               %(#{tabs}</#{key}>)
              ].join("\n")
            end
          else
            %(#{tabs}<#{key}>#{value}</#{key}>)
          end
        end.flatten.join("\n")
      end

      action(:create) do
        notifying_block do
          file new_resource.config_filename do
            content new_resource.content
          end
        end
      end

      action(:delete) do
        notifying_block do
          file new_resource.config_filename do
            action :delete
          end
        end
      end
    end
  end
end