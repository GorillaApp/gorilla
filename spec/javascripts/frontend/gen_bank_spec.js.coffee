#= require genbank
#= require logging
#= require jquery

testFile = """LOCUS       pGG001                  2559 bp ds-DNA   circular    UNK 01-JAN-1980
DEFINITION  .
ACCESSION   <unknown id>
VERSION     <unknown id>
KEYWORDS    .
SOURCE      .
ORGANISM  .
.
FEATURES             Location/Qualifiers
     misc_feature    join(1..10,12..12)
                     /ApEinfo_revcolor="#7f7f7f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
     misc_feature    14..14
                     /ApEinfo_revcolor="#66ccff"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="CamR Promoter"
                     /ApEinfo_fwdcolor="#66ccff"
                     /label="CamR Promoter"
ORIGIN
        1 cgtctctgac cagaccaata aaaaacgccc ggcggcaacc gagcgttctg aacaaatcca
       61 gatggagttc tgaggtcatt actggatcta tcaacaggag tccaagcgag ctcgatatca
//
"""

testFile2 = """LOCUS       pGG001                  2559 bp ds-DNA   circular    UNK 01-JAN-1980
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

window.logger = new Log(lc.all, ll.WARNING)

describe 'GenBank editor', ->
  it 'should be able to load a file without error', ->
    file = new GenBank(testFile)

  it 'should be able to serialize genes properly', ->
    file = new GenBank(testFile)
    genes = file.serializeGenes()
    genes.should.contain "ORIGIN"
    genes.should.contain "1 cgtctctgac cagaccaata aaaaacgccc ggcggcaacc gagcgttctg aacaaatcca"
    genes.should.contain "61 gatggagttc tgaggtcatt actggatcta tcaacaggag tccaagcgag ctcgatatca"
    genes.should.contain "//"

  it 'should be able to serialize features', ->
    file = new GenBank(testFile)
    features = file.serializeFeatures()
    features.should.contain "misc_feature    join(1..10,12..12)"
    features.should.contain "misc_feature    14..14"

  it 'should parse the gene sequence correctly', ->
    file = new GenBank(testFile2)
    file.getGeneSequence().should.equal('cgtctctgaccagaccaata')

  it 'should annotate a simple file correctly', ->
    file = new GenBank(testFile2)
    features = file.getAnnotatedSequence()
    features.should.contain "<span id='ColE1-0-0-default' class='ColE1-0' style='background-color:#7f7f7f'>cgtctctgac</span>cagaccaata"

  describe "locations", ->
    it 'should serialize a location correctly', ->
      loc = GenBank.serializeLocation(
        strand: 1
        ranges: [ { start: 0, end: 1, id: 0 }
                  { start: 2, end: 4, id: 1 } ])
      loc.should.equal "complement(join(1..2,3..5))"

    it 'should parse location correctly', ->
      data = GenBank.parseLocationData("complement(join(1..2,3..5))")

      data.strand.should.equal 1

      data.ranges.length.should.equal 2

      data.ranges[0].start.should.equal 0
      data.ranges[0].end.should.equal 1

      data.ranges[1].start.should.equal 2
      data.ranges[1].end.should.equal 4

    testLocations = [
      "complement(join(1..2,3..5))",
      "join(1..3,5..7,78..76)",
      "5..6",
      "complement(700..5555)"
    ]

    for location in testLocations
      it "should parse and re-encode #{location}", ->
        d = GenBank.parseLocationData(location)
        newLocation = GenBank.serializeLocation(d)
        newLocation.should.equal location
