require 'super_caller'

module Kernel

  alias old_raise raise

  def raise(*args)
    old_raise(*args)
  rescue Exception => e
    e.backtrace = super_caller[1..-1]
    old_raise e
  end

end

class Exception

  alias old_backtrace backtrace

  attr_reader :backtrace

  alias old_set_backtrace set_backtrace

  def backtrace=(backtrace)
    old_set_backtrace backtrace.map { |frame| frame.to_s }
    @backtrace = backtrace
  end

  alias set_backtrace backtrace=

end
