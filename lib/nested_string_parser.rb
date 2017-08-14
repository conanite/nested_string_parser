require "nested_string_parser/version"

module NestedStringParser
  class Node
    attr_accessor :nesting, :value, :parent, :children

    def initialize     s=nil ; @nesting, @value, @children = (s ? s.gsub(/^( *)[^ ].*/, '\1').length : -1), (s && s.strip), [] ; end
    def add_child?     child ; (child.nesting > self.nesting) ? add_child(child) : parent.add_child?(child)                    ; end
    def add_child      child ; @children << child ; child.parent = self ; child                                                ; end
    def nb?              str ; str && str.strip != ""                                                                          ; end
    def accept str=nil, *ss ; nb?(str) ? add_child?(Node.new(str)).accept(*ss) : (ss.size > 0 ? self.accept(*ss) : self)       ; end
    def root                 ; parent ? parent.root : self                                                                     ; end
    def format        indent ; "#{indent}#{value}\n#{children.map { |c| c.format "#{indent}  " }.join}"                        ; end
  end

  def self.parse str ; NestedStringParser::Node.new.accept(*str.split(/\n/)).root ; end
  module StringExtension ; def parse_nested_string ; NestedStringParser.parse self ; end ; end

  def self.patch ; ::String.send :include, StringExtension ; end
end
