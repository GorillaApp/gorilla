#= require edit
#= require jquery

testFile = """LOCUS       pGG001                  2559 bp ds-DNA   circular    UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    1..10
                     /ApEinfo_revcolor="#7f7f7f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
ORIGIN
        1 cgtctctgac cagaccaata
//
"""

describe "Gorilla Editor", ->
  it 'should be able to start editing', ->
    # $('body').html('<div id="ed"></div>')
    # ge = new GorillaEditor("#ed", testFile)
    # ge.startEditing()
