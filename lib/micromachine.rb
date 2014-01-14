# Copyright (c) 2009 Michel Martens
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
class MicroMachine
  InvalidEvent = Class.new(NoMethodError)

  attr :transitions_for
  attr :state

  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  def on key, &block
    @callbacks[key] << block
  end

  def when(event, transitions)
    transitions_for[event] = transitions
  end

  def trigger event
    if trigger?(event)
      @state = transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback| callback.call }
      true
    else
      false
    end
  end

  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    transitions_for[event][state] ? true : false
  end

  def events
    transitions_for.keys
  end

  def ==(some_state)
    state == some_state
  end
end
