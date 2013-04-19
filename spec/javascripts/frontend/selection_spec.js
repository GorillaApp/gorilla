#= require genbank
#= require jquery

smallOverlapFile = """LOCUS       pGG001       3 bp      ds-DNA circular UNK 01-JAN-1980
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
"""

simpleFile = """LOCUS       pGG001                  20 bp ds-DNA   circular    UNK 01-JAN-1980
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
"""

describe 'Selection methods', ->
  
  it 'should capitalize a selection', ->
    file = new G.GenBank(testFile)
    genes = file.serializeGenes()
    genes.should.contain "ORIGIN"
    genes.should.contain "1 cgtctctgac cagaccaata aaaaacgccc ggcggcaacc gagcgttctg aacaaatcca"
    genes.should.contain "61 gatggagttc tgaggtcatt actggatcta tcaacaggag tccaagcgag ctcgatatca"
    genes.should.contain "//"

  it 'should lower case a selection', ->
    file = new G.GenBank(testFile)
    features = file.serializeFeatures()
    features.should.contain "misc_feature    join(1..10,12..12)"
    features.should.contain "misc_feature    14..14"

  it 'should reverse complement a selection', ->
    file = new G.GenBank(testFile2)
    file.getGeneSequence().should.equal('cgtctctgaccagaccaata')

  it 'should split a feature into three upon revComp in middle of feature', ->
    file = new G.GenBank(testFile2)
    features = file.getAnnotatedSequence()
    features.should.contain "<span id='0-default' style='background-color:#7f7f7f' data-offsets='0:0' data-features='0:0'>cgtctctgac</span>cagaccaata"


  it 'should split a feature into two upon revComp from plain text into feature', ->
    loc = G.GenBank.serializeLocation(
      strand: 1
      ranges: [ { start: 0, end: 1, id: 0 }
                { start: 2, end: 4, id: 1 } ])
    loc.should.equal "complement(join(1..2,3..5))"

  it 'should split a feature into two upon revComp from feature into plain text', ->
    data = G.GenBank.parseLocationData("complement(join(1..2,3..5))")

    data.strand.should.equal 1

  it 'should split overlapping features for which the selection edges cut through', ->
    data = G.GenBank.parseLocationData("complement(join(1..2,3..5))")

    data.strand.should.equal 1


