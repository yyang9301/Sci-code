require 'pp'
class IRIDParser
  def initialize(infil,outfil)
    @fin=File.open(infil,"r")
    @fout=File.open(outfil,"w")
    @data=[]
  end

  def initialize_hash
    {:header => [], :data => []}
  end

  def parse
    section = initialize_hash
    is_header, is_data = true, false
    @fin.each do |line|

      line.chomp!
      next if line.empty?
      section[:header] << line if is_header
      section[:data]<< line if is_data
      case line
        when /Obs\s+\Nino3.4\s+SST/
          is_header, is_data = false, true
          next
        when /^\s*end/
          is_header, is_data = true, false
          section = process(section) unless section[:data].empty?
          next
      end
    end
    @data
  end

  def process(section)
      section[:data].pop
      @data << regroup(section[:data])
      initialize_hash
  end

  def regroup(data)
    data_hash={:data=>[], :models=>[], :kind=>[]}
    data.each do |arr|

      data_hash[:data]<<reformat_data(arr[0..35])
      tmp = (arr[38..-1]).split
      data_hash[:kind]<<arr[38]
      data_hash[:models]<<arr[39..49]
    end
    data_hash
  end

  def reformat_data(data)
    data.scan(/..../).map {|c| c.to_i}
  end
end

count = 0
infil="ensofcst_ALLto0313rename"
outfil="enso.iri.data"
parser=IRIDParser.new(infil,outfil)
arr=parser.parse
pp arr[0]
pp arr[-1]
p arr.length
