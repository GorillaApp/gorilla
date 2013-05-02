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

simpleTestFile = """LOCUS       pGG001                  2559 bp ds-DNA   circular    UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    2..2
                     /ApEinfo_revcolor="#7f7f7f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
ORIGIN
        1 cg
//
"""

describe "Gorilla Editor", ->
  context 'with a test file', ->
    beforeEach ->
      $('body').html('<div id="ed"></div>')
      @ge = new G.GorillaEditor("#ed", testFile)
      @editorId = '#ed .editor'

    context 'while viewing', ->
      beforeEach ->
        @ge.viewFile()

      it 'should be able to load the file', ->
        $(@editorId).text().should.equal("cgtctctgaccagaccaata")
        $('#ed-0').text().should.equal("cgtctctgac")

    context "while editing", ->
      beforeEach ->
        @ge.startEditing()

      it 'should be able to load file', ->
        $(@editorId).text().should.equal("cgtctctgaccagaccaata")
        $('#ed-0').text().should.equal("cgtctctgac")

      it 'should allow insertion', ->
        $('#ed-0').text().should.equal("cgtctctgac")
        Mouse.setCursorAt('ed-0', 3)
        Keyboard.type('gattaca')
        $('#ed-0').text().should.equal("cgt")
        document.getElementById('ed-0').nextSibling
                                       .wholeText.should.equal("gattaca")
        $('#ed-1').text().should.equal("ctctgac")

  context 'with a simple test file', ->
    beforeEach ->
        $('body').html('<div id="ed"></div>')
        @ge = new G.GorillaEditor("#ed", simpleTestFile)
        @ge.startEditing()

    it 'should be able to serialize properly after deleting', ->
        Mouse.setCursorAt('ed-0', 0)
        Keyboard.type('<delete>')
        $(@editorId).text().should.equal('c')
        @ge.file.serialize().should.not.contain('ColE1')
