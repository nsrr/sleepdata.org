# frozen_string_literal: true

# Helps simplify links across screen sizes for headers.
module HeaderHelper
  def reply_or(label)
    label_or(label, icon("fas", "reply"))
  end

  def plus_or(label)
    label_or(label, icon("fas", "plus"))
  end

  def pencil_or(label)
    label_or(label, icon("fas", "pencil-alt"))
  end

  def download_or(label)
    label_or(label, icon("fas", "download"))
  end

  def label_or(label, small_label)
    span_xs_sm = content_tag :span, class: "d-inline-block d-md-none" do
      small_label
    end
    span_md_lg = content_tag :span, label, class: %w(d-none d-md-inline-block)
    span_xs_sm + span_md_lg
  end
end
