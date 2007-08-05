require 'rubygems'
require 'inline'
require 'parse_tree'
require 'ruby2ruby'

module SuperCaller

  VERSION = '1.0.0'

  Frame = Struct.new :file, :line, :method_name, :self, :sexp

  class Frame
    def to_s
      if method_name then
        "%s:%d:in `%s'" % [file, line, method_name]
      else
        "%s:%d" % [file, line]
      end
    end

    alias to_str to_s

    def split(*args)
      to_s.split(*args)
    end

    def source
      return unless method_name
      sexp = Sexp.for self.self.class, method_name, true
      return if s(nil) == sexp
      RubyToRuby.new.process sexp rescue nil
    end
  end

  inline :C do |builder|
    builder.include '"ruby.h"'
    builder.include '"node.h"'
    builder.include '"env.h"'

    builder.prefix <<-'EOF'
    static VALUE rb_mSuperCaller = Qnil;
    static VALUE rb_cSuperCaller_Frame = Qnil;

    void add_to_parse_tree(VALUE ary,
                           NODE * n,
                           VALUE newlines,
                           ID * locals);

    static VALUE node_to_sexp(NODE * node) {
      VALUE sexp = rb_ary_new();

      add_to_parse_tree(sexp, node, Qfalse, NULL);

      if (RARRAY(sexp)->len == 0) {
        return Qnil;
      } else {
        return RARRAY(sexp)->ptr[0];
      }
    }
    EOF

    builder.c <<-'EOF'
    static VALUE
    super_caller() {
      struct FRAME * c_frame = ruby_frame;
      VALUE r_frame, stack, method_name;
      NODE * n;

      if (NIL_P(rb_cSuperCaller_Frame)) {
        rb_mSuperCaller =
          rb_const_get(rb_cObject, rb_intern("SuperCaller"));
        rb_cSuperCaller_Frame =
          rb_const_get(rb_mSuperCaller, rb_intern("Frame"));
      }

      stack = rb_ary_new();

      if (c_frame->last_func == ID_ALLOCATOR)
        c_frame = c_frame->prev;

      for (; c_frame && (n = c_frame->node); c_frame = c_frame->prev) {
        if (c_frame->prev && c_frame->prev->last_func) {
          if (c_frame->prev->node == n) {
            if (c_frame->prev->last_func == c_frame->last_func)
              continue;
          }

          method_name = ID2SYM(c_frame->prev->last_func);
        } else {
          method_name = Qnil;
        }

        r_frame = rb_funcall(rb_cSuperCaller_Frame, rb_intern("new"), 5,
                             rb_str_new2(n->nd_file),
                             INT2FIX(nd_line(n)),
                             method_name,
                             c_frame->self,
                             node_to_sexp(n));

        rb_ary_push(stack, r_frame);
      }

      return stack;
    }
    EOF
  end

end

class Object
  include SuperCaller
end

