
module Dyndnsd
  module Updater
    class CommandWithBindZone
      def initialize(config)
        @zone_file = config['zone_file']
        @command = config['command']
        @generator = Generator::Bind.new(config)
      end
      
      def update(zone)
        # write zone file in bind syntax
        File.open(@zone_file, 'w') { |f| f.write(@generator.generate(zone)) }
        # call user-defined command
        pid = fork do
          exec @command
        end
      end
    end
  end
end