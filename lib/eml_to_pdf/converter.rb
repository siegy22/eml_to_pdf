module EmlToPdf
  class Converter
    MIME_TYPES = {
      plain_text: "text/plain",
      html: "text/html"
    }

    def initialize(input_path, output_path, fallback_text)
      @input_path = input_path
      @fallback_text = fallback_text
      @output_path = output_path
    end

    def convert
      email = Email.new(@input_path, @fallback_text)
      html = email.to_html
      Wkhtmltopdf.convert(html, @output_path)
    end
  end
end
