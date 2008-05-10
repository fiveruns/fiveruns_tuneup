module Fiveruns
  module Tuneup
    module Instrumentation
      module Mongrel
        module HttpResponse
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def port_for(socket)
              if self.socket.respond_to?(:addr)
                # Vanilla Mongrel
                self.socket.addr[1]
              else
                # Swiftiply
                self.socket.port
              end
            end
            
            def start_with_fiveruns_manage(*args, &block)
              result = start_without_fiveruns_manage(*args, &block)
              port = port_for(socket)
              Fiveruns::Tuneup.tally :requests, :mongrel, nil, [:name, port]
              result
            end
            def write_with_fiveruns_manage(data, *args, &block)
              # Mongrel::HttpResponse#write(data) modifies `data', so need to get the size
              # before the method is invoked
              size = data.size
              result = write_without_fiveruns_manage(data, *args, &block)
              port = port_for(socket)
              Fiveruns::Tuneup.metrics_in :mongrel, nil, [:name, port] do |metrics|
                metrics[:bytes] += size
              end
              result              
            end
          end
        end
      end
    end
  end
end

