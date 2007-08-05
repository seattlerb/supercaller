= SuperCaller

A Kernel#caller enhancement

Documentation:

http://seattlerb.org/SuperCaller

File Bugs:

http://rubyforge.org/tracker/?func=add&group_id=1513&atid=5921

== DESCRIPTION:

SuperCaller adds a beefed-up version of Kernel#caller and a beefed up
version of Exception#backtrace.

== FEATURES/PROBLEMS:

* Can cause Ruby to crash when an Exception with SuperCaller's
  backtrace reaches the top level.

== SYNOPSIS:

Regular old Kernel#super_caller:

  require 'super_caller'
  
  def something() super_caller end
  stack = something
  p stack.first.file # => "-"
  p stack.first.line # => 4
  p stack.first.method_name # => nil
  p stack.first.self # => main
  p stack.first.sexp # => [:vcall, :super_caller]
  p stack.first.source # => "def something\n  super_caller\nend"

Fancy Exception#backtrace:

  require 'super_caller/exception'
  
  def raiser() raise end
  
  def raisee
    raiser
  rescue => e
    p e.backtrace.first.sexp
  end
  
  raiser # => [:vcall, :raise]

== INSTALL:

  sudo gem install SuperCaller

