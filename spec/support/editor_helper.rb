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

  def select_from(startId, startLocation, endId, endLocation)
    page.driver.execute_script <<-SCRIPT
      sel = window.getSelection();
      startId = document.getElementById('#{startId}').childNodes[0]
      endId = document.getElementById('#{endId}').childNodes[0]
      sel.removeAllRanges();
      l = document.createRange();
      l.setStart(startId, #{startLocation});
      l.setEnd(endId, #{endLocation});
      sel.addRange(l);
    SCRIPT
  end

  def serialize_file()
    page.driver.execute_script <<-SCRIPT
      val = G.main_editor.file.serialize();
      l = document.createTextNode(val);
      para = document.getElementById("main_editor");
      para.appendChild(l);
    SCRIPT
  end

  def simulate_click(id)
    page.driver.execute_script <<-SCRIPT
      $('##{id}').trigger('click');
    SCRIPT
  end

  def click_at(id, location)
    set_cursor_at(id, location)
    simulate_click(id)
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
      when :copy
        _trigger_event(:copy)
      when :cut
        _trigger_event(:cut)
      when :paste
        _trigger_event(:paste)
      end
    elsif thing.kind_of? Integer
      _type_raw(thing, type, ctrl)
    elsif thing.kind_of? String
      thing.each_char do |char|
        _type_raw(char.ord, type, ctrl)
      end
    end
  end

  def _trigger_event(type)
    page.driver.execute_script <<-SCRIPT
      $('#main_editor .editor').trigger('#{type.to_s}');
    SCRIPT
  end

  def _type_raw(code, type = :keypress, ctrl=false)
    page.driver.execute_script <<-SCRIPT
      event = $.Event('#{type.to_s}',{keyCode:#{code},ctrlKey:#{ctrl}});
      $('#main_editor .editor').trigger(event);
    SCRIPT
  end
end
