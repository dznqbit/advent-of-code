class Parser
  def initialize(input)
    @input = input
  end

  # Input types can be: WIRE (direct wire to wire), SIGNAL (signal to wire), or NOT / AND / OR / LSHIFT / RSHIFT
  # input_1 may be: wire_id, signal value
  # input_2 may be: wire_id, gate input value (for LSHIFT / RSHIFT)
  # Array of Arrays like: [wire_id, input_type, input_1, input_2]
  #
  def circuit_definitions
    split_lines.map do |line|
      input_definition, wire_id = line.split('->').map(&:strip)

      input_type, input_1, input_2 = if input_definition =~ /^\d+$/
        ['SIGNAL', input_definition, nil]
      elsif input_definition =~ /^[a-z]{2}$/
        ['WIRE', input_definition, nil]
      else
        if input_definition.start_with?('NOT')
          input_definition.split(' ')
        else
          left_input_name, op_name, right_input_name = input_definition.split(' ')
          [op_name, left_input_name, right_input_name]
        end
      end

      [wire_id, input_type, input_1, input_2]
    end
  end

  private

  def split_lines
    @input.split("\n")
  end
end
