module EmlToPdf
  class ExtractionStep
    MIME_TYPES = {
      plain_text: "text/plain",
      html: "text/html",
      multipart_alternative: "multipart/alternative"
    }

    def initialize(mail_or_part)
      @mail_or_part = mail_or_part
    end

    def next
      if multipart_alternative?(@mail_or_part)
        best_part = extract_best_part(@mail_or_part.parts)
        ExtractionStep.new(best_part)
      elsif @mail_or_part.multipart?
        ExtractionStepList.new(@mail_or_part.parts.map { |part| ExtractionStep.new(part) })
      else
        self
      end
    end

    def finished?
      !@mail_or_part.multipart?
    end

    def to_html
      text_body(@mail_or_part)
    end

    private
    def multipart_alternative?(part)
      part.mime_type == MIME_TYPES[:multipart_alternative]
    end

    def text_body(mail_or_part)
      if mail_or_part.mime_type == MIME_TYPES[:html] && !mail_or_part.attachment?
        mail_or_part.decoded
      elsif mail_or_part.mime_type == MIME_TYPES[:plain_text] && !mail_or_part.attachment?
        wrap_text_in_pre_tag(mail_or_part.decoded)
      else
        ""
      end
    end

    def extract_best_part(parts)
      parts.detect(&:multipart?) ||
        find_body_with_type(parts, :html) ||
        find_body_with_type(parts, :plain_text) ||
        EmlToPdf::EmptyPart.new
    end

    def find_body_with_type(parts, type)
      parts.detect do |part|
        part.mime_type == MIME_TYPES[type]
      end
    end

    def wrap_text_in_pre_tag(text)
      "<pre>#{text}</pre>"
    end
  end
end
