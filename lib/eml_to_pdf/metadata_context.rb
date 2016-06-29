require "filesize"
require "cgi"
require "ostruct"

module EmlToPdf
  class MetadataContext < OpenStruct
    def config
      EmlToPdf.configuration
    end

    def format_attachment_size(attachment)
      Filesize.from("#{attachment.body.decoded.size} B").pretty
    end

    def format_date(date)
      config.format_date(date)
    end

    def html_escape(str)
      CGI.escapeHTML(str)
    end

    def get_binding
      binding
    end
  end
end
