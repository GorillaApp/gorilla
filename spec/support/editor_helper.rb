module GorillaHelper
  include Capybara::DSL

  def set_cursor_at(id, location)
    page.driver.execute_script <<-SCRIPT
      sel = window.getSelection();
      id = document.getElementById('#{id}').childNodes[0]
      sel.removeAllRanges();
      l = document.createRange();
      l.setStart(id, #{location});
      l.collapse(true);
      sel.addRange(l);
    SCRIPT
  end

  def type(character, type = :keypress)
    type_code(character.ord, type)
  end

  def type_code(code, type = :keypress)
    page.driver.execute_script <<-SCRIPT
      event = $.Event('#{type.to_s}',{keyCode:#{code}});
      $('#main_editor').trigger(event);
    SCRIPT
  end

  def backspace
    type_code(8, :keydown)
  end
end
