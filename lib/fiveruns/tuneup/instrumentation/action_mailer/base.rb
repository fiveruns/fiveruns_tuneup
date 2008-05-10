module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionMailer
        module Base
          def self.included(base)
            Fiveruns::Tuneup.instrument base, InstanceMethods, ClassMethods
          end
          module ClassMethods
            def receive_with_fiveruns_manage(*args, &block)
              Fiveruns::Tuneup.tally :msg_recvs do
                receive_without_fiveruns_manage(*args, &block)
              end
            end
          end
          module InstanceMethods
            def deliver_with_fiveruns_manage!(*args, &block)
              Fiveruns::Tuneup.tally :msg_sents do
                deliver_without_fiveruns_manage!(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end