require 'benchmark'

module Benchmark
  class Suite
    @current = nil

    def self.current
      @current
    end

    def self.create
      if block_given?
        old = @current

        begin
          s = new
          @current = s
          yield s
          return s
        ensure
          @current = old
        end
      else
        @current = new
      end
    end

    class SimpleReport
      def initialize(s = nil, e = nil)
        @start = s
        @end = s
      end

      attr_reader :start, :end
    end

    def initialize
      @report = nil
      @reports = {}
      @order = []
      @quiet = false
      @verbose = false
    end

    attr_reader :reports, :report

    def quiet!
      @quiet = true
    end

    def quiet?
      @quiet
    end

    def warming(label, sec)
      return unless @verbose
      STDOUT.print "#{label.rjust(20)} warmup: #{sec}s"
    end

    def warmup_stats(time, cycles)
      return unless @verbose
      STDOUT.print " time=#{time}us, cycles=#{cycles}."
    end

    def running(label, sec)
      return unless @verbose
      STDOUT.puts " running: #{sec}s..."
    end

    def add_report(rep, location)
      if @report
        @report << rep
      else
        @report = [rep]
      end

      @report_location = location
    end

    def run(file)
      start = Time.now

      begin
        load file
      rescue Exception => e
        STDOUT.puts "\nError in #{file}:"
        if e.respond_to? :render
          e.render
        else
          STDOUT.puts e.backtrace
        end
        return
      end

      fin = Time.now

      if @report
        @reports[file] = @report
        @report = nil
      else
        @reports[file] = SimpleReport.new(start, fin)
      end

      @order << file
    end

    def display
      if @report
        file = @report_location ? @report_location.split(":").first : "<unknown.rb>"
        @order << file
        @reports[file] = [@report]
      end

      @order.each do |file|
        STDOUT.puts "#{file}:"
        reports = @reports[file]

        if reports.empty?
          STDOUT.puts "  NO REPORTS FOUND"
        else
          reports.each do |rep|
            STDOUT.puts "  #{rep}"
          end
        end
      end
    end
  end
end
