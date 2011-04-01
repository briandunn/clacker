class Array
  def sum(&block)
    inject(0) do |sum, i|
      sum + yield( i )
    end
  end
end

