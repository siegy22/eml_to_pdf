module EmlToPdf
  class Wkhtmltopdf
    class ConversionError < StandardError; end

    def self.convert(input, output_path)
      IO.popen("wkhtmltopdf --encoding utf-8 --footer-center [page] --footer-spacing 2.5 --quiet - #{output_path} 2>&1", "r+") do |pipe|
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
