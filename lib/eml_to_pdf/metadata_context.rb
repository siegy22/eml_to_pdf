require "filesize"
require "cgi"

module EmlToPdf
  class MetadataContext
    def initialize(metadata)
      metadata.each do |k, v|
        eval("@#{k}=v")
      end
    end

    def config
      EmlToPdf.configuration
    end

    def format_attachment_size(attachment)
      Filesize.from("#{attachment.body.decoded.size} B").pretty
    end

    def format_date(date)
      date.strftime(config.date_format)
    end

    def html_escape(str)
      CGI.escapeHTML(str)
    end

    def get_binding
      binding
    end
  end
end
