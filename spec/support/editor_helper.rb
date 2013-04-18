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

  def get_cursor_location()
    page.driver.evaluate_script <<-SCRIPT
    SCRIPT
  end

  def set_cursor_after(id, location)
    page.driver.execute_script <<-SCRIPT
      sel = window.getSelection();
      id = document.getElementById('#{id}').nextSibling
      sel.removeAllRanges();
      l = document.createRange();
      l.setStart(id, #{location});
      l.collapse(true);
      sel.addRange(l);
    SCRIPT
  end

  def type(thing, type=:keypress, ctrl=false)
    if thing.kind_of? Symbol
      case thing
      when :backspace
        _type_raw(8, :keydown)
      when :delete
        _type_raw(46, :keydown)
      when :undo
        _type_raw(90, :keydown, true)
      when :redo
        _type_raw(89, :keydown, true)
      end
    elsif thing.kind_of? Integer
      _type_raw(thing, type, ctrl)
    elsif thing.kind_of? String
      thing.each_char do |char|
        _type_raw(char.ord, type, ctrl)
      end
    end
  end

  def _type_raw(code, type = :keypress, ctrl=false)
    page.driver.execute_script <<-SCRIPT
      event = $.Event('#{type.to_s}',{keyCode:#{code},ctrlKey:#{ctrl}});
      $('#main_editor').trigger(event);
    SCRIPT
  end
end
