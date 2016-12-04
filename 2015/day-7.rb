#!/usr/bin/env ruby
# http://adventofcode.com/day/7
# Part 1: 16076 too high
# Part 1: 16075 too low !?!
$: << (File.join(`pwd`.chomp, 'lib'))

input = STDIN.read

require 'day-7/parser'
require 'logger'

STDOUT.sync = true
logger = Logger.new(nil)
logger.formatter = proc do |severity, datetime, progname, msg|
   "#{severity}\t#{msg}\n"
end

class Circuit
  def initialize(wires_to_inputs, logger)
    @wires_to_inputs = wires_to_inputs
    @wire_signal_cache = {}
    @logger = logger
  end

  def wire_input(wire)
    inputs = @wires_to_inputs[wire]

    unless inputs
      logger.error "Wire(\"#{wire}\") - no inputs"
    end

    inputs
  end

  def wire_signal(wire)
    if @wire_signal_cache[wire]
      # logger.debug "Wire(#{wire}) - cached value #{@wire_signal_cache[wire]}"
    else
      inputs = wire_input(wire)
      signal = input_value(inputs)
      # logger.debug "Wire(#{wire}) - cache miss #{signal}"
      input_calc_summary = "#{inputs[0]} #{signal(inputs[1])}"

      if inputs[2]
        input_calc_summary += " #{signal(inputs[2])}"
      end
      logger.debug "#{wire}: #{signal}\t(#{inputs.compact.join(', ')})\t(#{input_calc_summary})"
      @wire_signal_cache[wire] = signal
    end

    @wire_signal_cache[wire]
  end

  def reset_cache
    @wire_signal_cache = {}
  end

  def write_wire_signal(wire, signal)
    @wire_signal_cache[wire] = signal
  end

  private

  attr_reader :logger

  def signal(str)
    if str =~ /^\d+$/
      str.to_i
    elsif str
      wire_signal(str)
    end
  end

  def input_value(inputs)
    return nil if inputs.nil?

    input_type, input_1, input_2 = inputs

    case input_type
    when 'SIGNAL', 'WIRE'
      signal(input_1)
    else
      gate_value(input_type, input_1, input_2)
    end
  end

  def gate_value(gate_type, input_1, input_2)
    signal_1 = signal(input_1)
    signal_2 = signal(input_2)

    case gate_type
    when 'NOT'
      # Flips according to 2^16
      (signal_1 ^ (2**16 - 1))

    when 'AND'
      signal_1 & signal_2

    when 'OR'
      signal_1 | signal_2

    when 'RSHIFT'
      signal_1 >> signal_2

    when 'LSHIFT'
      signal_1 << signal_2

    else
      logger.error "Bad Gate Type \"#{gate_type}\""
      nil

    end
  end
end

cds = Parser.new(input).circuit_definitions
wires_to_inputs = Hash[*cds.flat_map { |c| [c[0], c[1..-1]] }]
circuit = Circuit.new(wires_to_inputs, logger)

wire_a_signal = circuit.wire_signal('a')
puts "Part 1: #{wire_a_signal}"

circuit.reset_cache
circuit.write_wire_signal('b', wire_a_signal)
wire_a_signal = circuit.wire_signal('a')
puts "Part 2: #{wire_a_signal}"
