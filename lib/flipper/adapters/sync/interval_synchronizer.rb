module Flipper
  module Adapters
    class Sync
      # Internal: Wraps a Synchronizer instance and only invokes it every
      # N seconds.
      class IntervalSynchronizer
        # Private: Number of seconds between syncs (default: 10).
        DEFAULT_INTERVAL = 10

        # Private
        def self.now_ms
          Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
        end

        # Public: The Float or Integer number of seconds between invocations of
        # the wrapped synchronizer.
        attr_reader :interval

        # Public: Initializes a new interval synchronizer.
        #
        # synchronizer - The Synchronizer to call when the interval has passed.
        # interval - The Integer number of milliseconds between invocations of
        #            the wrapped synchronizer.
        def initialize(synchronizer, interval: nil)
          @synchronizer = synchronizer
          @interval = interval || DEFAULT_INTERVAL
          # TODO: add jitter to this so all processes booting at the same time
          # don't phone home at the same time.
          @last_sync_at = 0
        end

        def call
          return unless time_to_sync?

          @last_sync_at = now_ms
          @synchronizer.call

          nil
        end

        private

        def time_to_sync?
          ((now_ms - @last_sync_at) / 1_000.0) >= @interval
        end

        def now_ms
          self.class.now_ms
        end
      end
    end
  end
end
