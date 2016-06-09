module EmlToPdf
  class EmptyPart
    def multipart?
      false
    end

    def attachment?
      false
    end

    def mime_type
      "text/plain"
    end

    def decoded
      "[Cannot create a preview of the mail]"
    end
  end
end
