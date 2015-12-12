#!/usr/bin/env ruby
# http://adventofcode.com/day/7

input = STDIN.read

class Gate
  def self.build(behavior, inputs)
    klass = case behavior
            when 'NOT'    then NotGate
            when 'AND'    then AndGate
            when 'OR'     then OrGate
            when 'LSHIFT' then LeftShiftGate
            when 'RSHIFT' then RightShiftGate
            else
              raise "WTF #{behavior}"
            end

    klass.new(*inputs)
  end

  def initialize(input_wire_1, input_wire_2 = nil)
    @input_wire_1 = input_wire_1
    @input_wire_2 = input_wire_2
  end

  def signal
    if signal_1 && signal_2
      calculate(signal_1, signal_2)
    else
      nil
    end
  end

  protected

  def signal_1
    @input_wire_1.signal
  end

  def signal_2
    @input_wire_2.signal
  end

  def shift_amount
    # Meh... Overload 2nd ctor argument
    @input_wire_2
  end
end

class NotGate < Gate
  def signal
    signal_1 = @input_wire_1.signal

    if signal_1
      # Flip bits assuming to 16 bit storage
      (signal_1 ^ (2**16 - 1))
    end
  end

  def to_s
    "NOT #{@input_wire_1.id}"
  end
end

class RightShiftGate < Gate
  def signal
    if signal_1
      signal_1 >> shift_amount
    end
  end
end

class LeftShiftGate < Gate
  def signal
    if signal_1
      puts "from input #{@input_wire_1} lshift #{signal_1} by #{shift_amount}"
      signal_1 << shift_amount
    end
  end
end

class AndGate < Gate
  def compute(signal_1, signal_2)
    signal_1 & signal_2
  end
end

class OrGate < Gate
  def compute(signal_1, signal_2)
    signal_1 | signal_2
  end
end

class SimpleInput
  attr_reader :signal

  def initialize(signal)
    @signal = signal
  end

  def to_s
    signal.to_s
  end
end

class Wire
  attr_accessor :input

  def initialize(id, input = nil)
    @id = id
    @input = input
  end

  def signal
    if input
      input.signal
    else
      puts "No signal for #{self}"
      nil
    end
  end

  def to_s
    "Wire(#{@id}) \"#{signal}\""
  end
end

class Circuit
  attr_reader :wires

  def initialize
    @wires = {}
  end

  def read_line(line)
    input_definition, wire_definition = line.split('->').map(&:strip)

    input = if input_definition =~ /^\d+$/
      # Signal input
      SimpleInput.new(input_definition.to_i)
    elsif input_definition =~ /^[a-z]{2}$/
      # Direct Wire-to-Wire assignment
      new_wire(input_definition)
    else
      # Gate input
      operation, input1, input2 = parse_gate_definition(input_definition)

      gate_args = case operation
                  when 'NOT'
                    # Only 1 input wire.
                    [new_wire(input1)]
                  when 'LSHIFT', 'RSHIFT'
                    # Only 1 input wire + an argument.
                    [new_wire(input1), input2.to_i]
                  else
                    # 2 input wires.
                    [new_wire(input1), new_wire(input2)]
                  end

      # Create Gate
      Gate.build(operation, gate_args)
    end

    # Create Wire
    wire = new_wire(wire_definition)
    wire.input = input
  end

  def to_s
    @wires.each do |w_id, wire|
      "#{wire.input} -> #{wire.id}"
    end
  end

  private

  def new_wire(wire_id, input = nil)
    @wires[wire_id] ||= Wire.new(wire_id, input)
  end

  def parse_gate_definition(s)
    if s.start_with?('NOT')
      s.split(' ')
    else
      left_wire_name, op_name, right_wire_name = s.split(' ')
      [op_name, left_wire_name, right_wire_name]
    end
  end
end

c = Circuit.new
lines = input.split("\n")
lines.each_with_index do |line, index|
  c.read_line(line)
end

puts "Part 1: #{c.wires['a'].signal}"
