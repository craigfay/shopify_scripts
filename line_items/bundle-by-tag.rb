# Apply discounts to products above a given quantity
# Discount only applies to items with the tag given in the first argument
# The new quantity of each product is given in cents
class BundleByTag
  def initialize(tag, quantity, cents)
    @tag = tag
    @quantity = quantity
    @cents = cents
  end
  
  # Apply the discount to a cart
  def run(cart)
    applicable_items = cart.line_items.select do |line_item|
      line_item.variant.product.tags.include? @tag
    end

    # bundle slots: The remaining amount of items that can be discounted
    bundle_slots = @quantity
    message = "Priced reduced by the #{@quantity} for $#{@cents / 100} bundle!"
    
    
    if (totalQuantity(applicable_items)) >= @quantity
      # Change the price of applicable items
      applicable_items.each do |item|
        if (bundle_slots < 1)
          break # The last of the bundle slots have been discounted
        end
          
        if (item.quantity > bundle_slots)
          # There are more products in the line item than bundle slots
          item_price = item.line_price * (1 / item.quantity)
          new_price = bundle_slots * Money.new(cents: @cents);
          new_price += item_price * (item.quantity - bundle_slots)
          item.change_line_price(new_price, message: message)
          bundle_slots = 0
        else
          # There are enough bundle slots left for each product in the line_item
          new_price = item.quantity * Money.new(cents: @cents)
          item.change_line_price(new_price, message: message)
          bundle_slots -= item.quantity;
        end
      end
    end
  end
  
  # Calculate the total quantity in a list of line items
  def totalQuantity(line_items)
    total = 0
    line_items.each do |line_item|
      total += line_item.quantity
    end
    total
  end
  
end

CAMPAIGNS = [
  BundleByTag.new('shirts', 3, 1000)
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart
