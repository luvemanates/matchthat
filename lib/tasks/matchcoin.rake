namespace :matchthat do
  desc "Mint matchcoin"
  task mint: [:environment] do
    exec("ruby lib/tasks/matchcoin.rb")
  end
  task go: [:environment] do
    exec("ruby lib/tasks/go.rb")
  end
end
