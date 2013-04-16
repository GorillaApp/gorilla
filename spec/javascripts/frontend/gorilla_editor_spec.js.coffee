#= require gorilla-editor
#= require genbank
#= require jquery
#= require helpers/keyboard_helper

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
  beforeEach ->
    $('body').html('<div id="ed"></div>')
    @ge = new G.GorillaEditor("#ed", testFile)

  context 'while viewing', ->
    beforeEach ->
      @ge.viewFile()

    it 'should be able to load the file', ->
      $('#ed').text().should.equal("cgtctctgaccagaccaata")
      $('#ColE1-0-0-ed').text().should.equal("cgtctctgac")

  context "while editing", ->
    beforeEach ->
      @ge.startEditing()
      
    it 'should be able to load file', ->
      $('#ed').text().should.equal("cgtctctgaccagaccaata")
      $('#ColE1-0-0-ed').text().should.equal("cgtctctgac")

    it 'should allow insertion', ->
      $('#ColE1-0-0-ed').text().should.equal("cgtctctgac")
      Mouse.setCursorAt('ColE1-0-0-ed', 3)
      Keyboard.type('gattaca')
      $('#ColE1-0-0-ed').text().should.equal("cgt")
      document.getElementById('ColE1-0-0-ed').nextSibling
                                             .wholeText.should.equal("gattaca")
      $('#ColE1-1-0-ed').text().should.equal("ctctgac")
