
class Numeric
  def square ; self * self ; end
end

class Stats
  def self.sum(array) ; array.inject(0){|a,x|x+a} ; end
  def self.mean(array) ; sum(array).to_f/array.size ; end
  def self.median(array)
    case array.size % 2
      when 0 then Stats.mean(array.sort[array.size/2-1,2])
      when 1 then array.sort[array.size/2].to_f
    end if array.size > 0
  end
  def self.histogram(array) ; array.sort.inject({}){|a,x|a[x]=a[x].to_i+1;a} ; end
  def self.mode(array)
    map = histogram(array)
    max = map.values.max
    map.keys.select{|x|map[x]==max}
  end
  def self.squares(array) ; array.inject(0){|a,x|x.square+a} ; end
  def self.variance(array) ; squares(array).to_f/array.size - mean(array).square; end
  def self.deviation(array) ; Math::sqrt( variance(array) ) ; end
  def self.sample(array) n=1 ; (0...n).collect{ array[rand(array.size)] } ; end
  def self.quartiles(array)
    median = Stats.median(array)
    less_than = array.select {|x| x < median }
    greater_than = array.select {|x| x > median }
    [Stats.median(less_than), median, Stats.median(greater_than)]
  end
  
  def self.deciles(array)
    len = array.length
    decile_width = len / 10.0
    result = []
    sorted_vals = array.sort
    10.times do |i|
      upper_bound = (i+1)*decile_width
      matching = sorted_vals[0..(upper_bound-1)]
      result << matching.last
    end
    result
  end
end