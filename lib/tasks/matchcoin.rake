namespace :matchthat do
  desc "Mint matchcoin"
  task mint: :environment do
    exec("ruby lib/tasks/matchcoin.rb")
  end
end
