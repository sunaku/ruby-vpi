if RubyVPI::USE_PROTOTYPE
  always do
    wait until DUT.<%= aModuleInfo.clock_port.name rescue "YOUR_CLOCK_SIGNAL_HERE" %>.posedge?

    # discard old outputs
    <% aModuleInfo.output_ports.each do |port| %>
      DUT.<%= port.name %>.x!
    <% end %>

    # process new inputs
    <% aModuleInfo.input_ports.each do |port| %>
      # some_interesting_process( DUT.<%= port.name %> )
    <% end %>

    # produce new outputs
    <% aModuleInfo.output_ports.each do |port| %>
      # DUT.<%= port.name %> = some interesting output
    <% end %>
  end
end
