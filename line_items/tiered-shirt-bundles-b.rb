# Represents the logic of bundling shirts: 3 for $60, 2 for $45
class TieredShirtBundles
  def initialize()
    # The discount amount for a shirt that's included in a bundle of 3, and 2 respectively
    @discount_per_item_in_bundle_of_three = Money.new(cents: 600)
    @discount_per_item_in_bundle_of_two = Money.new(cents: 350)
  end
  
  # Apply the discount to a cart
  def run(cart)
    # Each line_item has a quantity, which usually makes the total...
    # ...quantity of items higher than the length of cart.line_items
    total_item_count = 0
    applicable_line_items = cart.line_items.select do |line_item|
      is_shirt = line_item.variant.product.tags.include? 'shirts'
      is_bundle = line_item.variant.product.tags.include? 'bundle'
      if is_shirt and is_bundle
        total_item_count += line_item.quantity
        line_item
      end
    end

    # The remaining amount of items that can be discounted in each category
    items_in_bundles_of_3 = (total_item_count / 3).floor * 3
    items_in_bundles_of_2 = ((total_item_count % 3) / 2).floor * 2
  
    # Change the price of applicable items
    applicable_line_items.each do |line_item|
      unexamined_item_count = line_item.quantity
      if items_in_bundles_of_3 >= unexamined_item_count
        discount = unexamined_item_count * @discount_per_item_in_bundle_of_three
        line_item.change_line_price(line_item.line_price - discount, message: "")
        items_in_bundles_of_3 -= unexamined_item_count
        next
      end
      if items_in_bundles_of_3 > 0 and items_in_bundles_of_3 < unexamined_item_count
        discount = items_in_bundles_of_3 * @discount_per_item_in_bundle_of_three
        line_item.change_line_price(line_item.line_price - discount, message: "")
        unexamined_item_count -= items_in_bundles_of_3
        items_in_bundles_of_3 = 0
      end
      if items_in_bundles_of_2 >= unexamined_item_count
        discount = unexamined_item_count * @discount_per_item_in_bundle_of_two
        line_item.change_line_price(line_item.line_price - discount, message: "")
        items_in_bundles_of_2 -= unexamined_item_count
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
