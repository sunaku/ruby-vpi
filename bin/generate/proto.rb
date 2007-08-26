always do
  wait until <%= aModuleInfo.clock_port.name rescue "YOUR_CLOCK_SIGNAL_HERE" %>.posedge?

  # discard old outputs
  <% aModuleInfo.output_ports.each do |port| %>
    <%= port.name %>.x!
  <% end %>

  # process new inputs
  <% aModuleInfo.input_ports.each do |port| %>
    # some_interesting_process( <%= port.name %> )
  <% end %>

  # produce new outputs
  <% aModuleInfo.output_ports.each do |port| %>
    # <%= port.name %> = some interesting output
  <% end %>
end
