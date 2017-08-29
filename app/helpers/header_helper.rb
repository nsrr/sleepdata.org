# frozen_string_literal: true

# Helps simplify links across screen sizes for headers.
module HeaderHelper
  def reply_or(label)
    label_or(label, reply_tag)
  end

  def plus_or(label)
    label_or(label, plus_tag)
  end

  def pencil_or(label)
    label_or(label, generic_tag("fa-pencil"))
  end

  def download_or(label)
    label_or(label, generic_tag("fa-download"))
  end

  def label_or(label, small_label)
    span_xs_sm = content_tag :span, class: "d-inline-block d-md-none" do
      small_label
    end
    span_md_lg = content_tag :span, label, class: %w(d-none d-md-inline-block)
    span_xs_sm + span_md_lg
  end

  def plus_tag
    content_tag :i, nil, class: %w(fa fa-plus), aria: { hidden: "true" }
  end

  def reply_tag
    content_tag :i, nil, class: %w(fa fa-reply), aria: { hidden: "true" }
  end

  def generic_tag(fa_class)
    content_tag :i, nil, class: ["fa", fa_class], aria: { hidden: "true" }
  end
end
