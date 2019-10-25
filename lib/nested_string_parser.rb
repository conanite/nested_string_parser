require "nested_string_parser/version"

module NestedStringParser
  class Node
    attr_accessor :nesting, :value, :parent, :children

    def initialize     s=nil ; @nesting, @value, @children = (s ? s.gsub(/^( *)[^ ].*/, '\1').length : -1), (s && s.strip), [] ; end
    def add_child?     child ; (child.nesting > self.nesting) ? add_child(child) : parent.add_child?(child)                    ; end
    def add_child      child ; @children << child ; child.parent = self ; child                                                ; end
    def nest_child     child ; add_child(child).tap { |c| c.nesting = nesting + 1 }                                            ; end
    def nb?              str ; str && str.strip != ""                                                                          ; end
    def accept str=nil, *ss ; nb?(str) ? add_child?(Node.new(str)).accept(*ss) : (ss.size > 0 ? self.accept(*ss) : self)       ; end
    def root                 ; parent ? parent.root : self                                                                     ; end
    def format        indent ; %[#{indent}#{value}\n#{children.map { |c| c.format "#{indent}  " }.join}]                       ; end
    def find            name ; children.detect { |k| k.value == name }                                                         ; end
  end

  # rows is an array of arrays
  # | A | B | C |
  # | A | B | D |
  # | A | E | F |
  # | A | E | G |
  # | B | H | J |
  # | B | H | K |
  # same as
  # A
  #   B
  #     C
  #     D
  #   E
  #     F
  #     G
  # B
  #   H
  #     J
  #     K
  #
  def self.from_rows rows, root=new_node
    rows.each { |row| row.inject(root) { |node, name| node.find(name) || (node.nb?(name) && node.nest_child(new_node name)) || node } }
    root
  end

  def self.new_node     val=nil ; NestedStringParser::Node.new.tap { |n| n.value = val }        ; end
  def self.parse            str ; new_node.accept(*str.split(/\n/)).root                        ; end
  module Extension              ; def parse_nested_string ; NestedStringParser.parse self.to_s  ; end ; end
  def self.patch klass=::String ; klass.send :include, Extension                                ; end
end
