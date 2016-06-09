module EmlToPdf

  # TODO: in email#to_html remove recursive function with this class
  # for a better control and to be able to make more unit tests.
  class ExtractionStep
    def initialize(mail_or_part)
      @mail_or_part = mail_or_part
    end

    # extraction = ExtractionStep.new(@mail)
    # extraction = extraction.next until extraction.finished?

    def next
      if multipart_alternative?(@mail_or_part)
        best_part = extract_best_part(@mail_or_part.parts)
        ExtractionStep.new(best_part)
      elsif @mail_or_part.multipart?

      else

      end
    end

    def finished?
      @mail_or_part.parts.none?(&:multipart?)
    end

    def to_html
      if html_part = @mail_or_part.html_part
        html_part
      elsif text_part = @mail_or_part.text_part
        wrap_text_in_pre_tag(text_part)
      else
        ""
      end
    end

    def extract_best_part(parts)
      if multipart_part = parts.detect(&:multipart?)
        multipart_part
      elsif html_part = find_body_with_type(parts, :html)
        html_part
      elsif text_part = find_body_with_type(parts, :plain_text)
        text_part
      else
        "can't find useable part"
      end
    end

    def multipart_alternative?(part)
      part.mime_type == MIME_TYPES[:multipart_alternative]
    end

    def wrap_text_in_pre_tag(text)
      "<pre>#{text}</pre>"
    end
  end
end
