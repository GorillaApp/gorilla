require 'spec_helper'

describe Autosave do
  it "checks to see if find_autosaved_file correctly returns nil" do
    result = Autosave.find_autosaved_file("Not a valid entry")
    result.should eql(nil)
  end

  it "checks to see if find_autosaved_file correctly returns the file" do
    file_contents = <<-EOF
LOCUS       pGG002                  2559 bp ds-DNA   circular    UNK 01-JAN-1980
DEFINITION  .
ACCESSION   <unknown id>
VERSION     <unknown id>
KEYWORDS    .
SOURCE      .
  ORGANISM  .
            .
FEATURES             Location/Qualifiers
     misc_feature    complement(888..1651)
                     /ApEinfo_revcolor="#7f7f7f"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="ColE1"
                     /ApEinfo_fwdcolor="#7f7f7f"
                     /label="ColE1"
     misc_feature    complement(783..887)
                     /ApEinfo_revcolor="#66ccff"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="CamR Promoter"
                     /ApEinfo_fwdcolor="#66ccff"
                     /label="CamR Promoter"
     misc_feature    complement(123..782)
                     /ApEinfo_revcolor="#0000ff"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="CamR"
                     /ApEinfo_fwdcolor="#0000ff"
                     /label="CamR"
     misc_feature    complement(14..122)
                     /ApEinfo_revcolor="#66ccff"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="CamR Terminator"
                     /ApEinfo_fwdcolor="#66ccff"
                     /label="CamR Terminator"
     misc_feature    join(1..6,8..11)
                     /ApEinfo_revcolor="#e72e00"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="BsmBI"
                     /ApEinfo_fwdcolor="#00ff15"
                     /label="BsmBI"
     misc_feature    complement(join(1659..1664,1654..1657))
                     /ApEinfo_revcolor="#e72e00"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="BsmBI"
                     /ApEinfo_fwdcolor="#00ff15"
                     /label="BsmBI"
     misc_feature    1665..1743
                     /ApEinfo_revcolor="#ff9d9a"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="Tet Promoter"
                     /ApEinfo_fwdcolor="#ff9d9a"
                     /label="Tet Promoter"
     misc_feature    1744..2421
                     /ApEinfo_revcolor="#c16969"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="RFP"
                     /ApEinfo_fwdcolor="#c16969"
                     /label="RFP"
     misc_feature    2422..2559
                     /ApEinfo_revcolor="#ff9d9a"
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}"
                     /ApEinfo_label="Terminator"
                     /ApEinfo_fwdcolor="#ff9d9a"
                     /label="Terminator"
ORIGIN
        1 cgtctctgac cagaccaata aaaaacgccc ggcggcaacc gagcgttctg aacaaatcca
       61 gatggagttc tgaggtcatt actggatcta tcaacaggag tccaagcgag ctcgatatca
      121 aattacgccc cgccctgcca ctcatcgcag tactgttgta attcattaag cattctgccg
      181 acatggaagc catcacaaac ggcatgatga acctgaatcg ccagcggcat cagcaccttg
      241 tcgccttgcg tataatattt gcccatggtg aaaacggggg cgaagaagtt gtccatattg
      301 gccacgttta aatcaaaact ggtgaaactc acccagggat tggctgaaac gaaaaacata
      361 ttctcaataa accctttagg gaaataggcc aggttttcac cgtaacacgc cacatcttgc
      421 gaatatatgt gtagaaactg ccggaaatcg tcgtggtatt cactccagag cgatgaaaac
      481 gtttcagttt gctcatggaa aacggtgtaa caagggtgaa cactatccca tatcaccagc
      541 tcaccgtctt tcattgccat acgaaattcc ggatgagcat tcatcaggcg ggcaagaatg
      601 tgaataaagg ccggataaaa cttgtgctta tttttcttta cggtctttaa aaaggccgta
      661 atatccagct gaacggtctg gttataggta cattgagcaa ctgactgaaa tgcctcaaaa
      721 tgttctttac gatgccattg ggatatatca acggtggtat atccagtgat ttttttctcc
      781 attttagctt ccttagctcc tgaaaatctc gataactcaa aaaatacgcc cggtagtgat
      841 cttatttcat tatggtgaaa gttggaacct cttacgtgcc cgatcaatca tgaccaaaat
      901 cccttaacgt gagttttcgt tccactgagc gtcagacccc gtagaaaaga tcaaaggatc
      961 ttcttgagat cctttttttc tgcgcgtaat ctgctgcttg caaacaaaaa aaccaccgct
     1021 accagcggtg gtttgtttgc cggatcaaga gctaccaact ctttttccga aggtaactgg
     1081 cttcagcaga gcgcagatac caaatactgt tcttctagtg tagccgtagt taggccacca
     1141 cttcaagaac tctgtagcac cgcctacata cctcgctctg ctaatcctgt taccagtggc
     1201 tgctgccagt ggcgataagt cgtgtcttac cgggttggac tcaagacgat agttaccgga
     1261 taaggcgcag cggtcgggct gaacgggggg ttcgtgcaca cagcccagct tggagcgaac
     1321 gacctacacc gaactgagat acctacagcg tgagctatga gaaagcgcca cgcttcccga
     1381 agggagaaag gcggacaggt atccggtaag cggcagggtc ggaacaggag agcgcacgag
     1441 ggagcttcca gggggaaacg cctggtatct ttatagtcct gtcgggtttc gccacctctg
     1501 acttgagcgt cgatttttgt gatgctcgtc aggggggcgg agcctatgga aaaacgccag
     1561 caacgcggcc tttttacggt tcctggcctt ttgctggcct tttgctcaca tgttctttcc
     1621 tgcgttatcc cctgattctg tggataaccg tagtcggcga gacgtcccta tcagtgatag
     1681 agattgacat ccctatcagt gatagagata ctgagcacgg atctgaaaga ggagaaagga
     1741 tctatggcga gtagcgaaga cgttatcaaa gagttcatgc gtttcaaagt tcgtatggaa
     1801 ggttccgtta acggtcacga gttcgaaatc gaaggtgaag gtgaaggtcg tccgtacgaa
     1861 ggtacccaga ccgctaaact gaaagttacc aaaggtggtc cgctgccgtt cgcttgggac
     1921 atcctgtccc cgcagttcca gtacggttcc aaagcttacg ttaaacaccc ggctgacatc
     1981 ccggactacc tgaaactgtc cttcccggaa ggtttcaaat gggaacgtgt tatgaacttc
     2041 gaagacggtg gtgttgttac cgttacccag gactcctccc tgcaagacgg tgagttcatc
     2101 tacaaagtta aactgcgtgg taccaacttc ccgtccgacg gtccggttat gcagaaaaaa
     2161 accatgggtt gggaagcttc caccgaacgt atgtacccgg aagacggtgc tctgaaaggt
     2221 gaaatcaaaa tgcgtctgaa actgaaagac ggtggtcact acgacgctga agttaaaacc
     2281 acctacatgg ctaaaaaacc ggttcagctg ccgggtgctt acaaaaccga catcaaactg
     2341 gacatcacct cccacaacga agactacacc atcgttgaac agtacgaacg tgctgaaggt
     2401 cgtcactcca ccggtgctta ataaggatct ccaggcatca aataaaacga aaggctcagt
     2461 cgaaagactg ggcctttcgt tttatctgtt gtttgtcggt gaacgctctc tactagagtc
     2521 acactggctc accttcgggt gggcctttct gcgtttata
//
EOF
    first_line = file_contents.split(/\r?\n/)[0]
    time = Time.now.to_s
    user_id = 1
    Autosave.save_file(file_contents, first_line, time, user_id)
    result = Autosave.find_autosaved_file(first_line)
    result.should_not be_nil
 end
end


