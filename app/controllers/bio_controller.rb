class BioController < ApplicationController
  def align
    request[:sequences] ||= []
    seqs = request[:sequences].collect { |seq| Bio::Sequence::NA.new(seq) }
    align = Bio::Alignment.new(seqs)
    factory = Bio::ClustalW.new
    alignment = factory.query_alignment(align)
    render json: alignment
  end
end
