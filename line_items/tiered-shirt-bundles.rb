# Represents the logic of bundling shirts: 3 for $60, 2 for $45
def tiered_shirt_bundles()
  def initialize()
    # Items with this tag will have the discount applied
    @tag = 'shirts'

    # The discount amount for a shirt that's included in a bundle of 3, and 2 respectively
    @discount_of_3 = Money.new(cents: 600)
    @discount_of_2 = Money.new(cents: 350)
  end
  
  # Apply the discount to a cart
  def run(cart)
    total_shirts = 0 # total shirts to discount
    applicable_items = cart.line_items.select do |line_item|
      if line_item.variant.product.tags.include? @tag
        total_shirts += line_item.quantity
        line_item
      end
    end

    # The remaining amount of items that can be discounted in each category
    threes = (total_shirts / 3).floor * 3
    twos = ((total_shirts % 3) / 2).floor * 2
  
    # Change the price of applicable items
    applicable_items.each do |item|
      for q in 1..item.quantity
        if threes > 0
          new_price = item.line_price - @discount_of_3
          threes -= 1
          item.change_line_price(new_price, message: "")
        elsif twos > 0
          new_price = item.line_price - @discount_of_2
          twos -= 1
          item.change_line_price(new_price, message: "")
        end
      end
    end
  end
end

CAMPAIGNS = [
  TieredShirtBundles.new()
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart
