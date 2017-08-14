require 'spec_helper'
require "nested_string_parser"

RSpec::describe NestedStringParser do
  before(:all) { NestedStringParser.patch }
  it "parses nothing at all" do
    node = "".parse_nested_string
    expect(node.value   ).to eq nil
    expect(node.nesting ).to eq(-1)
    expect(node.children).to eq []
  end

  it "parses a single line" do
    node = "foo bar hello world".parse_nested_string
    expect(node.value        ).to eq nil
    expect(node.nesting      ).to eq(-1)
    expect(node.children.size).to eq 1

    child = node.children.first
    expect(child.value   ).to eq "foo bar hello world"
    expect(child.nesting ).to eq 0
    expect(child.children).to eq []
  end

  it "parses two root lines" do
    node = "foo bar\nhello world".parse_nested_string
    expect(node.value        ).to eq nil
    expect(node.nesting      ).to eq(-1)
    expect(node.children.size).to eq 2

    child = node.children[0]
    expect(child.value   ).to eq "foo bar"
    expect(child.nesting ).to eq 0
    expect(child.children).to eq []

    child = node.children[1]
    expect(child.value   ).to eq "hello world"
    expect(child.nesting ).to eq 0
    expect(child.children).to eq []
  end

  CANONICAL_QUARKS = <<STRING
quarks
  G1
    up
    down
  G2
    strange
    charmed
  G3
    top
    bottom
leptons
  G1
    electron
    electron neutrino
  G2
    muon
    muon neutrino
  G3
    tau
    tau neutrino
STRING

  it "parses a whole hierarchy" do
    node = CANONICAL_QUARKS.parse_nested_string
    expect(node.value                ).to eq nil
    expect(node.nesting              ).to eq(-1)
    expect(node.children.map(&:value)).to eq %w{ quarks leptons }

    quarks = node.children[0]
    expect(quarks.nesting                ).to eq 0
    expect(quarks.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(quarks.children.map(&:nesting)).to eq [2,2,2]
    expect(quarks.children.map { |q| q.children.map(&:nesting) }).to eq [[4,4], [4,4], [4,4]]
    expect(quarks.children.map { |q| q.children.map(&:value)   }).to eq [%w{up down}, %w{strange charmed}, %w{top bottom}]

    leptons = node.children[1]
    expect(leptons.nesting                ).to eq 0
    expect(leptons.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(leptons.children.map(&:nesting)).to eq [2,2,2]
    expect(leptons.children.map { |q| q.children.map(&:nesting) }).to eq [[4,4], [4,4], [4,4]]
    expect(leptons.children.map { |q| q.children.map(&:value)   }).to eq [%w{electron electron\ neutrino}, %w{muon muon\ neutrino}, %w{tau tau\ neutrino}]

    expect(node.children.map { |c| c.format "" }.join.strip).to eq CANONICAL_QUARKS.strip
  end

  it "parses a sloppy indentation and ignores blank lines" do
    string = <<STRING
quarks
  G1
    up
    down

  G2
     strange
   charmed
  G3
                        top
    bottom
leptons
  G1
                   electron

                   electron neutrino
 G2
                muon
    muon neutrino
 G3
  tau

  tau neutrino


STRING
    node = string.parse_nested_string
    expect(node.value                ).to eq nil
    expect(node.nesting              ).to eq(-1)
    expect(node.children.map(&:value)).to eq %w{ quarks leptons }

    quarks = node.children[0]
    expect(quarks.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(quarks.children.map { |q| q.children.map(&:value)   }).to eq [%w{up down}, %w{strange charmed}, %w{top bottom}]

    leptons = node.children[1]
    expect(leptons.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(leptons.children.map { |q| q.children.map(&:value)   }).to eq [%w{electron electron\ neutrino}, %w{muon muon\ neutrino}, %w{tau tau\ neutrino}]

    # #format, however, ignores original indentation
    expect(node.children.map { |c| c.format "" }.join.strip).to eq CANONICAL_QUARKS.strip
  end
end
