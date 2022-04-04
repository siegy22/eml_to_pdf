module EmlToPdf
  class ExtractionStepList
    def initialize(steps)
      @steps = steps
    end

    def next
      self.class.new(@steps.map(&:next))
    end

    def build_emls
      self.class.new(@steps.map(&:build_emls))
    end

    def finished?
      @steps.all?(&:finished?)
    end

    def to_html
      @steps.flatten.map(&:to_html).join
    end

    private
    def multipart_alternative?(part)
      part.mime_type == MIME_TYPES[:multipart_alternative]
    end
  end
end
