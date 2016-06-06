module EmlToPdf
  class Converter
    def initialize(input_path, output_path)
      @input_path = input_path
      @output_path = output_path
    end

    def convert
      email = Email.new(@input_path)
      html = email.to_html
      Wkhtmltopdf.convert(html, @output_path)
    end
  end
end
