module ModelHelper 

  # def self.project(hash, keys)
  #   hash.slice(*keys)
  # end

  # キー名をキャメルケースに変換したハッシュを返す
  # 返されるハッシュのそれぞれの値にはStringとSymbolの両方のキーでアクセスできるようになる
  def camelized_attributes
    self.attributes()
      .transform_keys() { |key| key.camelize(:lower) }
      .with_indifferent_access()
  end
end