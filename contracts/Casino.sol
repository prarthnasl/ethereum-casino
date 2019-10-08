pragma solidity ^0.5.8;

contract Casino {
   address owner;

   uint public minimumBet = 100 finney; // Equal to 0.1 ether
   uint public totalBet;
   uint public numberOfBets;
   uint public maxAmountOfBets = 2;
   uint public constant LIMIT_AMOUNT_BETS = 100;
   uint public numberWinner;

   // Array of players
   address[] public players;

   // Each number has an array of players. Associate each number with a bunch of players
   mapping(uint => address[]) numberBetPlayers;

   // The number that each player has bet for
   mapping(address => uint) playerBetsNumber;

   // Modifier to only allow the execution of functions when the bets are completed
   modifier onEndGame(){
      if(numberOfBets >= maxAmountOfBets) _;
   }

   function Casino(uint _minimumBet, uint _maxAmountOfBets){
      owner = msg.sender;

      if(_minimumBet > 0) minimumBet = _minimumBet;
      if(_maxAmountOfBets > 0 && _maxAmountOfBets <= LIMIT_AMOUNT_BETS)
         maxAmountOfBets = _maxAmountOfBets;
   }

   function checkPlayerExists(address player) returns(bool){
      if(playerBetsNumber[player] > 0)
         return true;
      else
         return false;
   }

   function bet(uint numberToBet) payable {

      require(numberOfBets < maxAmountOfBets);
      require(checkPlayerExists(msg.sender) == false);
      require(numberToBet >= 1 && numberToBet <= 10);
      require(msg.value >= minimumBet);

      // Set the number bet for that player
      playerBetsNumber[msg.sender] = numberToBet;

      // The player msg.sender has bet for that number
      numberBetPlayers[numberToBet].push(msg.sender);

      numberOfBets += 1;
      totalBet += msg.value;

      if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   function generateNumberWinner() payable onEndGame {
     uint256 numberGenerated = block.number % 10 + 1;
     distributePrizes(numberGenerated);
   }

   /// Sends the corresponding Ether to each winner then deletes all the
   /// players for the next game and resets the `totalBet` and `numberOfBets`
   function distributePrizes() onEndGame {
      uint winnerEtherAmount = totalBet / numberBetPlayers[numberWinner].length; // How much each winner gets

      // Loop through all the winners to send the corresponding prize for each one
      for(uint i = 0; i < numberBetPlayers[numberWinner].length; i++){
         numberBetPlayers[numberWinner][i].transfer(winnerEtherAmount);
      }

      // Delete all the players for each number
      for(uint j = 1; j <= 10; j++){
         numberBetPlayers[j].length = 0;
      }

      totalBet = 0;
      numberOfBets = 0;
   }
}
