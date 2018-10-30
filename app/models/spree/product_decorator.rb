Spree::Product.class_eval do

  has_many :sale_prices, through: :prices

  # Essentially all read values here are delegated to reading the value on the Master variant
  # All write values will write to all variants (including the Master) unless that method's all_variants parameter is
  # set to false, in which case it will only write to the Master variant.

  delegate_missing_to :variant
  delegate_missing_to :price

  # TODO also accept a class reference for calculator type instead of only a string
  def put_on_sale(value, params = {})
    all_variants = params[:all_variants] || true
    run_on_variants(all_variants) { |v| v.put_on_sale(value, params) }
    self.touch
  end

  alias :create_sale :put_on_sale

  def enable_sale(all_variants = true)
    run_on_variants(all_variants) { |v| v.enable_sale }
    self.touch
  end

  def disable_sale(all_variants = true)
    run_on_variants(all_variants) { |v| v.disable_sale }
    self.touch
  end

  def start_sale(end_time = nil, all_variants = true)
    run_on_variants(all_variants) { |v| v.start_sale(end_time) }
    self.touch
  end

  def stop_sale(all_variants = true)
    run_on_variants(all_variants) { |v| v.stop_sale }
    self.touch
  end

  private
    def run_on_variants(all_variants, &block)
      if all_variants && variants.present?
        variants.each { |v| block.call v }
      end
      block.call master
    end

end
