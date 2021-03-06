class SyncEntriesUsingBankCrawler < PowerTypes::Command.new(:product, :payload)

  def perform
    bank_entries = crawler_command.for(payload: @payload)
    SignEntries.for(bank_entries: bank_entries)
    create_new_entries(bank_entries)
  end

  private

  def crawler_command
    @product.crawler_command_name.constantize
  end

  def create_new_entries(bank_entries)
    bank_entries.each do |bank_entry|
      entry = Entry.find_or_create_by(product_id: @product.id, signature: bank_entry.signature)
      sign = bank_entry.type == :deposit ? 1 : -1

      entry.update_attributes(
        description: bank_entry.description,
        amount: bank_entry.amount * sign,
        date: bank_entry.date
      )
    end
  end
end
