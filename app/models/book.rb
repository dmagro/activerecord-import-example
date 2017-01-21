class Book < ApplicationRecord
	has_many :sentences, dependent: :destroy
end
