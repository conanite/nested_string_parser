require 'spec_helper'
require "nested_string_parser"

RSpec::describe NestedStringParser do
  it "parses nothing at all" do
    node = NestedStringParser.from_rows []

    expect(node.value   ).to eq nil
    expect(node.nesting ).to eq(-1)
    expect(node.children).to eq []
  end

  it "parses a single item" do
    node = NestedStringParser.from_rows [["hello"]]

    expect(node.value        ).to eq nil
    expect(node.nesting      ).to eq(-1)
    expect(node.children.size).to eq 1

    child = node.children.first
    expect(child.value   ).to eq "hello"
    expect(child.nesting ).to eq 0
    expect(child.children).to eq []
  end

  QUARKS_IN_ROWS = [
    %w{ quarks G1 up                 },
    %w{ quarks G1 down               },
    %w{ quarks G2 strange            },
    %w{ quarks G2 charmed            },
    %w{ quarks G3 top      \         },
    %w{ quarks G3 bottom             },
    %w{ leptons G1 electron          },
    %w{ leptons G1 electron-neutrino },
    %w{ leptons G2 muon              },
    %w{ leptons G2 muon-neutrino  \  },
    %w{ leptons G3 tau               },
    %w{ leptons G3 tau-neutrino      },
  ]

  it "parses a whole csv file" do
    node = NestedStringParser.from_rows QUARKS_IN_ROWS

    expect(node.value                ).to eq nil
    expect(node.nesting              ).to eq(-1)
    expect(node.children.map(&:value)).to eq %w{ quarks leptons }

    quarks = node.children[0]
    expect(quarks.nesting                ).to eq 0
    expect(quarks.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(quarks.children.map(&:nesting)).to eq [1,1,1]
    expect(quarks.children.map { |q| q.children.map(&:nesting) }).to eq [[2,2], [2,2], [2,2]]
    expect(quarks.children.map { |q| q.children.map(&:value)   }).to eq [%w{up down}, %w{strange charmed}, %w{top bottom}]

    leptons = node.children[1]
    expect(leptons.nesting                ).to eq 0
    expect(leptons.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(leptons.children.map(&:nesting)).to eq [1,1,1]
    expect(leptons.children.map { |q| q.children.map(&:nesting) }).to eq [[2,2], [2,2], [2,2]]
    expect(leptons.children.map { |q| q.children.map(&:value)   }).to eq [%w{electron electron-neutrino}, %w{muon muon-neutrino}, %w{tau tau-neutrino}]
  end

  QUARKS_IN_SPARSE_ROWS = [
    %w{ quarks  G1 up                 },
    %w{ \       \  down               },
    %w{ \       G2 strange            },
    %w{ \       \  charmed            },
    %w{ \       G3 top      \         },
    %w{ \       \  bottom             },
    %w{ leptons G1 electron          },
    %w{ \       \  electron-neutrino },
    %w{ \       G2 muon              },
    %w{ \       \  muon-neutrino  \  },
    %w{ \       G3 tau               },
    %w{ \       \  tau-neutrino      },
  ]

  it "parses a whole csv file with parent-items inherited from previous row" do
    node = NestedStringParser.from_rows QUARKS_IN_SPARSE_ROWS

    expect(node.value                ).to eq nil
    expect(node.nesting              ).to eq(-1)
    expect(node.children.map(&:value)).to eq %w{ quarks leptons }

    quarks = node.children[0]
    expect(quarks.nesting                ).to eq 0
    expect(quarks.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(quarks.children.map(&:nesting)).to eq [1,1,1]
    expect(quarks.children.map { |q| q.children.map(&:nesting) }).to eq [[2,2], [2,2], [2,2]]
    expect(quarks.children.map { |q| q.children.map(&:value)   }).to eq [%w{up down}, %w{strange charmed}, %w{top bottom}]

    leptons = node.children[1]
    expect(leptons.nesting                ).to eq 0
    expect(leptons.children.map(&:value)  ).to eq %w{ G1 G2 G3 }
    expect(leptons.children.map(&:nesting)).to eq [1,1,1]
    expect(leptons.children.map { |q| q.children.map(&:nesting) }).to eq [[2,2], [2,2], [2,2]]
    expect(leptons.children.map { |q| q.children.map(&:value)   }).to eq [%w{electron electron-neutrino}, %w{muon muon-neutrino}, %w{tau tau-neutrino}]
  end

  ENGLISH_CURRICULUM = [
    ["English", "Grammar"   , "Verbs"     , "Past"         ],
    [""       , ""          , ""          , "Present"      ],
    [""       , ""          , ""          , "Future"       ],
    [""       , ""          , ""          , ""             ],
    [""       , ""          , "Adjectives", ""             ],
    [""       , ""          , ""          , ""             ],
    [""       , ""          , "Nouns"     , "Proper"       ],
    [""       , ""          , ""          , "Pronouns"     ],
    [""       , ""          , ""          , "Other"        ],
    [""       , ""          , ""          , ""             ],
    [""       , ""          , "Sentences" , "Introduction" ],
    [""       , ""          ,  ""         , "Structure"    ],
    [""       , ""          ,  ""         , "Clauses"      ],
    [""       , ""          ,  ""         , "Conjunctions" ],
    [""       , ""          , ""          , ""             ],
    [""       , "Literature", "Stories"   , ""             ],
    [""       , ""          , "Novels"    , ""             ],
    [""       , ""          , "Drama"     , ""             ],
    [""       , ""          , "Poetry"    , ""             ],
    [""       , ""          , "Criticism" , ""             ],
  ]

  it "parses a whole csv file with parent-items inherited from previous row, ignoring empty rows and empty trailing cells" do
    node = NestedStringParser.from_rows ENGLISH_CURRICULUM

    expected = <<FORMATTED

  English
    Grammar
      Verbs
        Past
        Present
        Future
      Adjectives
      Nouns
        Proper
        Pronouns
        Other
      Sentences
        Introduction
        Structure
        Clauses
        Conjunctions
    Literature
      Stories
      Novels
      Drama
      Poetry
      Criticism
FORMATTED

    expect(node.format("")).to eq expected
  end
end
