<h1>MatchThat</h1>
A ruby on rails application that allows users to participate in matching programs.  When a new match is created, new matchcoin, a cryptocurrency is minted and stored in the mongo database. Also others can opt to match what others are matching on the web app.  The matchcoin also contains scripts in lib/tasks that generate minted cryptocurrency matchcoin every few seconds.  


<h2>MatchCoin</h2>
There is a whole library in lib/tasks with two scripts
lib/tasks/matchthat_mintserver.rb
which you run with 
ruby matchthat_mintserver.rb
and
lib/tasks/matchcoinbank_mintclient.rb
which you run by 
ruby matchcoinbank_mintclient.rb

The server mints new coins, and the client adds them to the bank wallet.  

Also, when you create new matches new coin is minted as well.
