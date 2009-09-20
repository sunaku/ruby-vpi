class Summer
  def sum(max)
    raise "Invalid maximum #{max}" if max < 0
    (max*max + max)/2
  end
end

puts 'heya!! in sum.rb'
p __FILE__
p $0
