module AgreementsHelper

  def status_helper(agreement)
    status_hash = { 'approved' => 'success',
                    'resubmit' => 'danger',
                    'submitted' => 'primary',
                    'expired' => 'default',
                    '' => 'warning'
                  }
    content_tag(
      :span, agreement.status.blank? ? 'started' : agreement.status,
      class: "label label-#{status_hash[agreement.status.to_s]}"
    )
  end

  def step_helper(agreement, step, selected_step)
    if step == selected_step
      'primary'
    elsif step == 6
      'warning'
    elsif agreement.step_valid?(step)
      'success'
    else
      'warning'
    end
  end

  def find_diff(word_one, word_two, phrase_size = word_one.to_s.split('').size)
    return [] if phrase_size == 0

    word_one_array = word_one.to_s.split('')
    word_two = word_two.to_s

    word_one_mask = Array.new(word_one_array.size, false)

    index_start = nil
    index_end = nil
    word_two_index_start = nil
    word_two_index_end = nil

    word_one_array.each_cons(phrase_size).each_with_index do |phrase, index|
      regex_expression = Regexp.escape(phrase.join(''))
      if result_at = word_two.match(regex_expression)
        (word_two_index_start, word_two_index_end) = result_at.offset(0)
        index_start = index
        index_end = (index+phrase.size-1)
        word_one_mask[index_start..index_end] = Array.new(index_end - index_start+1, true)
        break
      end
    end

    if index_start and index_end
      word_one_mask[0..index_start-1] = find_diff(word_one_array[0..index_start-1].join(''), word_two[0..word_two_index_start-1]) if index_start > 0
      word_one_mask[index_end+1..-1] = find_diff(word_one_array[index_end+1..-1].join(''), word_two[word_two_index_end..-1]) if index_end < word_one_array.size
    else
      word_one_mask = find_diff(word_one, word_two, phrase_size - 1) if phrase_size - 1 > 0
    end

    return word_one_mask
  end

end
