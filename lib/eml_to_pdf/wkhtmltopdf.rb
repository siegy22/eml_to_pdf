module EmlToPdf
  class Wkhtmltopdf
    def self.convert(input, output_path)
      IO.popen("wkhtmltopdf --encoding utf-8 --footer-center [page] - #{output_path} 2>&1", "r+") do |pipe|
        pipe.puts(input)
        pipe.close_write
        pipe.readlines # TODO save output
      end
    end
  end
end
