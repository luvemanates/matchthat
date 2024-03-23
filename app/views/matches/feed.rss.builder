xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "MatchThat Ledger"
    xml.description "Exposing the ledger Bank Wallet of the matchcoin"
    for block in @ledger_entry_blocks
      xml.item do
        xml.type block.ledger_entry_type
        xml.coin_serial_number block.coin_serial_number
        xml.coin_face_value block.coin_face_value
        xml.entry_amount block.entry_amount
        xml.id block.id
      end
    end
  end
end

