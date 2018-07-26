# ブックデータのハッシュインスタンスにミックスインするためのモジュール
# ミックスインすることで2つのブックハッシュ集合の差集合を求めることができるようになる
module BookCollater
  def eql?(other)
    self[:isbn] == other[:isbn]
  end

  def hash
    self[:isbn].hash()
  end
end