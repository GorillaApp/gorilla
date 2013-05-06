#= require gorilla-editor
#= require genbank
#= require selection
#= require jquery
#= require helpers/keyboard_helper

smallOverlapFile = '''LOCUS pGG001    3 bp      ds-DNA circular UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    1..2
                     /ApEinfo_revcolor="#1f1f1f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
     misc_feature    2..3
                     /ApEinfo_revcolor="#7e7e7e"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#6f6f6f"
                     /label="ColE2"
ORIGIN
        1 atc
//
'''

simpleFile = '''LOCUS       pGG001   20 bp ds-DNA   circular    UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    5..15
                     /ApEinfo_revcolor="#1f1f1f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
ORIGIN
        1 cgtctctgac cagaccaata
//
'''

describe 'selection methods', ->

  it 'should reverse complement a selection', ->
    file = new G.GenBank(simpleFile)
    G.reverseCompSelection([0,5],file,true)
    f = file.serialize()
    f.should.contain("complement(1..1)")
    f.should.contain("6..15")

  it 'should split a feature into three upon revComp in middle of feature', ->
    file = new G.GenBank(simpleFile)
    G.reverseCompSelection([6,9],file,true)
    f = file.serialize()
    f.should.contain("complement(7..9)")
    f.should.contain("5..6")
    f.should.contain("10..15")

  it 'should split a feature in two upon revComp ' +
     'from feature into plain text', ->
    file = new G.GenBank(simpleFile)
    G.reverseCompSelection([9,17],file,true)
    f = file.serialize()
    f.should.contain("complement(12..17)")
    f.should.contain("5..9")



