class Board
  include Enumerable
  
  attr_reader :hash

  SPACES = %i{tl tc tr cl cc cr bl bc br}
  EMPTY_MARK = '.' 
  X_MARK = 'X'
  O_MARK = 'O'

  def initialize
    @hash = {}
    SPACES.each { |sp| @hash[sp] = EMPTY_MARK }
  end

  def []=(key, value)
    raise ArgumentError, "#{key} is not a valid space!" unless SPACES.include? key
    @hash[key] = value 
  end

  def [](key)
    @hash[key]
  end

  def select(&block)
    @hash.select &block
  end

  def print
    <<-eos
     #{@hash[:tl]} | #{@hash[:tc]} | #{@hash[:tr]}
    -----------
     #{@hash[:cl]} | #{@hash[:cc]} | #{@hash[:cr]}
    -----------
     #{@hash[:bl]} | #{@hash[:bc]} | #{@hash[:br]}
    
    eos
  end

  def to_s
    "#{@hash}"
  end
end
