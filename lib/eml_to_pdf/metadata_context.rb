require 'filesize'

module EmlToPdf
  class MetadataContext
    def initialize(metadata)
      metadata.each do |k, v|
        eval("@#{k}=v")
      end
    end

    def format_attachment_size(attachment)
      Filesize.from("#{attachment.body.decoded.size} B").pretty
    end

    def format_date(date)
      date.strftime("%d.%m.%Y um %H:%M")
    end

    def get_binding
      binding
    end
  end
end
