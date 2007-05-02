require 'rdoc/usage'

module RDoc
  # Display usage information from RDoc comments in the given file.
  #--
  # Copyright (c) 2001-2003 Dave Thomas.
  # Released under the same license as Ruby.
  def RDoc.usage_from_file input_file, *args
    comment = File.open(input_file) do |file|
      find_comment(file)
    end

    comment = comment.gsub(/^\s*#/, '')

    markup = SM::SimpleMarkup.new
    flow_convertor = SM::ToFlow.new

    flow = markup.convert(comment, flow_convertor)

    format = "plain"

    unless args.empty?
      flow = extract_sections(flow, args)
    end

    options = RI::Options.instance
    if args = ENV["RI"]
      options.parse(args.split)
    end
    formatter = options.formatter.new(options, "")
    formatter.display_flow(flow)
  end
end
