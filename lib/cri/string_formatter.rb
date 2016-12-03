require 'colored'

module Cri
  class StringFormatter
    # Extracts individual paragraphs (separated by two newlines).
    #
    # @param [String] s The string to format
    #
    # @return [Array<String>] A list of paragraphs in the string
    def to_paragraphs(s)
      lines = s.scan(/([^\n]+\n|[^\n]*$)/).map { |l| l[0].strip }

      paragraphs = [[]]
      lines.each do |line|
        if line.empty?
          paragraphs << []
        else
          paragraphs.last << line
        end
      end

      paragraphs.reject(&:empty?).map { |p| p.join(' ') }
    end

    # Word-wraps and indents the string.
    #
    # @param [String] s The string to format
    #
    # @param [Number] width The maximal width of each line. This also includes
    #   indentation, i.e. the actual maximal width of the text is
    #   `width`-`indentation`.
    #
    # @param [Number] indentation The number of spaces to indent each line.
    #
    # @param [Boolean] first_line_already_indented Whether or not the first
    #   line is already indented
    #
    # @return [String] The word-wrapped and indented string
    def wrap_and_indent(s, width, indentation, first_line_already_indented = false)
      indented_width = width - indentation
      indent = ' ' * indentation
      # Split into paragraphs
      paragraphs = to_paragraphs(s)

      # Wrap and indent each paragraph
      text = paragraphs.map do |paragraph|
        # Initialize
        lines = []
        line = ''

        # Split into words
        paragraph.split(/\s/).each do |word|
          # Begin new line if it's too long
          if (line + ' ' + word).length >= indented_width
            lines << line
            line = ''
          end

          # Add word to line
          line += (line == '' ? '' : ' ') + word
        end
        lines << line

        # Join lines
        lines.map { |l| indent + l }.join("\n")
      end.join("\n\n")

      if first_line_already_indented
        text[indentation..-1]
      else
        text
      end
    end

    # @param [String] s The string to format
    #
    # @return [String] The string, formatted to be used as a title in a section
    #   in the help
    def format_as_title(s, io)
      if Cri::Platform.color?(io)
        s.upcase.red.bold
      else
        s.upcase
      end
    end

    # @param [String] s The string to format
    #
    # @return [String] The string, formatted to be used as the name of a command
    #   in the help
    def format_as_command(s, io)
      if Cri::Platform.color?(io)
        s.green
      else
        s
      end
    end

    # @param [String] s The string to format
    #
    # @return [String] The string, formatted to be used as an option definition
    #   of a command in the help
    def format_as_option(s, io)
      if Cri::Platform.color?(io)
        s.yellow
      else
        s
      end
    end
  end
end
