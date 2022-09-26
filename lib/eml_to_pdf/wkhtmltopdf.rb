require 'timeout'

module EmlToPdf
  class Wkhtmltopdf
    class ConversionError < StandardError; end
    class ConversionTimeoutError < StandardError
      def message
        "Failed to convert within the configured timeout. Use EmlToPdf.configure to increase the timeout if needed."
      end
    end

    def self.convert(input, output_path)
      security_options = ""
      EmlToPdf.configuration.security_options.each do |option|
        security_options += "#{option} "
      end
      os_command = <<~INFO
        #{EmlToPdf.configuration.wkhtmltopdf} #{security_options}
        --encoding utf-8 --footer-center [page] --footer-spacing 2.5 --quiet - #{output_path} 2>&1
      INFO
      os_command.gsub!("\n", '')
      Timeout.timeout(EmlToPdf.configuration.timeout, ConversionTimeoutError) do
        IO.popen(os_command, "r+") do |pipe|
          pipe.puts(input)
          pipe.close_write
          output = pipe.readlines.join
          pipe.close
          unless $?.success?
            raise ConversionError, output
          end
        end
      end
    end
  end
end
