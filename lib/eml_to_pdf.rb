require "cgi"
require "mail"
require "erb"
require "nokogiri"
require "filesize"
require "eml_to_pdf/version"
require "eml_to_pdf/converter"
require "eml_to_pdf/converter"
require "eml_to_pdf/email"
require "eml_to_pdf/wkhtmltopdf"
require "eml_to_pdf/metadata_context"

module EmlToPdf
  def self.convert(input, output, fallback_text: "No preview available")
    Converter.new(input, output, fallback_text).convert
  end
end
