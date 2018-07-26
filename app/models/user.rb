# ユーザーのモデルクラス
class User < ApplicationRecord
  include ModelHelper
  
  attr_accessor :role

  # 現時点ではユーザーは1つだけの本棚を持つこととする（今後複数の本棚を持つユースケースはあるかもしれない）
  has_one(:bookshelf, dependent: :destroy)
  has_many(:reviews, dependent: :destroy)
  has_many(:books, through: :reviews)
  has_many(:active_relationships, class_name: 'UserRelationship', foreign_key: 'follower_id', dependent: :destroy)
  has_many(:following, through: :active_relationships, source: :followed)
  has_many(:passive_relationships, class_name: 'UserRelationship', foreign_key: 'followed_id', dependent: :destroy)
  has_many(:followers, through: :passive_relationships, source: :follower)

  before_save() do
    username.downcase!()
    email.downcase!()
  end

  # Usernameに使える文字はアルファベットと数字と-のみ
  # ただし-を連続で使用するのはNG
  # 最初と最後が-になるのもNG
  # このルールはGitHubを参考にした
  VALID_USERNAME_REGEX = /\A[a-zA-Z\d](?:[a-zA-Z\d]|-(?!(?:-|\z)))*\z/
  validates(:username, {
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 32 },
    format: { with: VALID_USERNAME_REGEX }
  })

  validates(:name, {
    presence: true,
    length: { maximum: 255 }
  })

  VALID_MAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, {
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 255 },
    format: { with: VALID_MAIL_REGEX }
  })

  has_secure_password()
  validates(:password, {
    presence: true,
    length: { in: 8..64 },
    format: { with: /\A[x21-x7E]{8,64}\z/ },
    allow_nil: true
  })

  # セキュリティに関するカラム以外を取得するセキュアなSELECT
  scope(:secure_select, -> { select(:id, :username, :name, :email, :created_at, :updated_at) })
  # 他テーブルがもつユーザーに関連するデータをキャッシュするスコープ
  scope(:caching_user, -> { includes(:bookshelf, :books, :passive_relationships, :active_relationships) })
  
  # デフォルトではセキュリティに関するカラムは取得しない
  default_scope(-> { secure_select() })

  # 本をユーザーが所持している（本棚に格納している）かをブールで返す
  def has?(book)
    self.bookshelf().books().include?(book)
    # 上のロジックから下のロジックにするとバグがでた
    # self.books().include?(book)
  end

  def is?(other)
    self == other
  end

  def follow(other_user)
    self.active_relationships().create(followed: other_user)
  end

  def unfollow(other_user)
    self.active_relationships().find_by(followed: other_user).destroy()
  end

  def following?(other_user)
    self.following().include?(other_user)
  end

  # キーをキャメルケースに変換したモデルのハッシュにいくつかの追加情報を付け加えて返す
  def camelized_attributes_with_additional_info
    camelized_attributes().merge({
      bookshelfId: self.bookshelf.id,
      followersCount: self.passive_relationships().size(),
      followingCount: self.active_relationships().size()
    })
  end

  # ユーザーが管理者かどうかをブールで返す
  def admin?
    true
  end
end
