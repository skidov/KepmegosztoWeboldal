require "test_helper"

class FavouriteTest < ActiveSupport::TestCase
    test "cannot save favourite with existing" do
        f = Favourite.new(user_id: favourites(:one).user_id, image_id: favourites(:one).image_id)
        assert !f.save, "A favourite elmentődött" 
    end
end
