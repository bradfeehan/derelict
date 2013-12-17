module Derelict
  # Executes an external (shell) command "safely"
  #
  # The safety involved is mainly ensuring that the command is
  # gracefully terminated if this process is about to terminate.
  class Executer
    attr_reader :stdout, :stderr

    # Executes <tt>command</tt> and returns after execution
    #
    #   * command: A string containing the command to run
    #   * options: A hash of options, with the following (symbol) keys:
    #      * :mode:      Controls how the process' output is given to
    #                    the block, one of :chars (pass each character
    #                    one by one, retrieved with getc), or :lines
    #                    (pass only whole lines, retrieved with gets).
    #                    (optional, defaults to :lines)
    #      * :no_buffer: If true, the process' stdout and stderr won't
    #                    be collected in the stdout and stderr
    #                    properties, and will only be passed to the
    #                    block (optional, defaults to false)
    #   * block:   Gets passed stdout and stderr every time the process
    #              outputs to each stream (first parameter is stdout,
    #              second parameter is stderr; only one will contain
    #              data, the other will be nil)
    def self.execute(command, options = {}, &block)
      self.new(options).execute(command, &block)
    end


    # Initializes an Executer instance with particular options
    #
    #   * options: A hash of options, with the following (symbol) keys:
    #      * :mode:      Controls how the process' output is given to
    #                    the block, one of :chars (pass each character
    #                    one by one, retrieved with getc), or :lines
    #                    (pass only whole lines, retrieved with gets).
    #                    (optional, defaults to :lines)
    #      * :no_buffer: If true, the process' stdout and stderr won't
    #                    be collected in the stdout and stderr
    #                    properties, and will only be passed to the
    #                    block (optional, defaults to false)
    def initialize(options = {})
      @options = {:mode => :lines, :no_buffer => false}.merge(options)

      if @options[:mode] == :chars
        @reader = proc {|s| s.getc }
      else
        @reader = proc {|s| s.gets }
      end

      @mutex = Mutex.new
      reset
    end

    # Executes <tt>command</tt> and returns after execution
    #
    #   * command: A string containing the command to run
    #   * block:   Gets passed stdout and stderr every time the process
    #              outputs to each stream (first parameter is stdout,
    #              second parameter is stderr; only one will contain
    #              data, the other will be nil)
    def execute(command, &block)
      reset
      pid, stdin, stdout_stream, stderr_stream = Open4::popen4(command)
      stdin.close rescue nil

      save_exit_status(pid)
      forward_signals_to(pid) do
        handle_streams stdout_stream, stderr_stream, &block
      end

      self
    ensure
      stdout.close rescue nil
      stderr.close rescue nil
    end

    # Determines whether the last command was successful or not
    #
    # If the command's exit status was zero, this will return true.
    # If the command's exit status is anything else, this will return
    # false. If a command is currently running, this will return nil.
    def success?
      @success
    end

    private
      # Clears the variables relating to a particular command execution
      #
      # This is done when first initialising, and just before a command
      # is run, to get rid of the previous command's data.
      def reset
        @stdout = ''
        @stderr = ''
        @success = nil
      end

      # Waits for the exit status of a process (in a thread) saving it
      #
      # This will set the @status instance variable to true if the exit
      # status was 0, or false if the exit status was anything else.
      def save_exit_status(pid)
        @success = nil
        Thread.start do
          @success = (Process.waitpid2(pid).last.exitstatus == 0)
        end
      end

      # Forward signals to a process while running the given block
      #
      #   * pid:     The process ID to forward signals to
      #   * signals: The names of the signals to handle (optional,
      #              defaults to SIGINT only)
      def forward_signals_to(pid, signals = %w[INT])
        # Set up signal handlers
        signal_count = 0
        signals.each do |signal|
          Signal.trap(signal) do
            Process.kill signal, pid rescue nil

            # If this is the second time we've received and forwarded
            # on the signal, make sure next time we just give up.
            reset_handlers_for signals if ++signal_count >= 2
          end
        end

        # Run the block now that the signals are being forwarded
        yield
      ensure
        # Always good to make sure we clean up after ourselves
        reset_handlers_for signals
      end

      # Resets the handlers for particular signals to the default
      #
      #   * signals: An array of signal names to reset the handlers for
      def reset_handlers_for(signals)
        signals.each {|signal| Signal.trap signal, "DEFAULT" }
      end

      # Manages reading from the stdout and stderr streams
      #
      #   * stdout_stream: The process' stdout stream
      #   * stderr_stream: The process' stderr stream
      #   * block:         The block to pass output to (optional)
      def handle_streams(stdout_stream, stderr_stream, &block)
        streams = [stdout_stream, stderr_stream]
        until streams.empty?
          # Find which streams are ready for reading, timeout 0.1s
          selected, = select(streams, nil, nil, 0.1)

          # Try again if none were ready
          next if selected.nil? or selected.empty?

          selected.each do |stream|
            if stream.eof?
              streams.delete(stream) unless @success.nil?
              next
            end

            while data = @reader.call(stream)
              data = ((@options[:mode] == :chars) ? data.chr : data)
              stream_name = (stream == stdout_stream) ? :stdout : :stderr
              output data, stream_name, &block unless block.nil?
              buffer data, stream_name unless @options[:no_buffer]
            end
          end
        end
      end

      # Outputs data to the block
      #
      #   * data:        The data that needs to be passed to the block
      #   * stream_name: The stream data came from (:stdout or :stderr)
      #   * block:       The block to pass the data to
      def output(data, stream_name = :stdout, &block)
        # Pass the output to the block
        if block.arity == 2
          args = [nil, nil]
          if stream_name == :stdout
            args[0] = data
          else
            args[1] = data
          end
          block.call(*args)
        else
          yield data if stream_name == :stdout
        end
      end

      # Buffers data for a stream into this object to retrieve it later
      #
      #   * data:        The data that should be added to the buffer
      #   * stream_name: Which stream the data came from (:stdout or
      #                  :stderr)
      def buffer(data, stream_name)
        if stream_name == :stdout
          @stdout += data
        else
          @stderr += data
        end
      end
  end
end
