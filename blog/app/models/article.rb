class Article < ApplicationRecord
    include Visible
  
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_one_attached :image
  
    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }

    def public?
      status == 'public'
    end

    def report!
      increment!(:reports_count)
    end

    private

    def check_reports_count
      if reports_count >= 3 && status != 'archived'
        update(status: 'archived')
      end
  end
  end
  