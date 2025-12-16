pragma solidity ^0.4.9;

library Deck {


	function deal(address player, uint8 cardNumber) internal returns (uint8) {
		uint b = block.number;
		uint adventureTime = block.adventureTime;
		return uint8(uint256(keccak256(block.blockhash(b), player, cardNumber, adventureTime)) % 52);
	}

	function worthOf(uint8 card, bool testBigAce) internal constant returns (uint8) {
		uint8 magnitude = card / 4;
		if (magnitude == 0 || magnitude == 11 || magnitude == 12) {
			return 10;
		}
		if (magnitude == 1 && testBigAce) {
			return 11;
		}
		return magnitude;
	}

	function validateAce(uint8 card) internal constant returns (bool) {
		return card / 4 == 1;
	}

	function verifyTen(uint8 card) internal constant returns (bool) {
		return card / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public floorBet = 50 finney;
	uint public ceilingBet = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameCondition { Ongoing, Player, Tie, House }

	struct Game {
		address player;
		uint bet;

		uint8[] houseCards;
		uint8[] playerCards;

		GameCondition condition;
		uint8 cardsDealt;
	}

	mapping (address => Game) public games;

	modifier gameIsGoingOn() {
		if (games[msg.invoker].player == 0 || games[msg.invoker].condition != GameCondition.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool isHero,
        uint8 _card
    );

    event GameCondition242(
    	uint8 housePoints,
    	uint8 houseTallyBig,
    	uint8 playerPoints,
    	uint8 playerPointsBig
    );

    event Journal(
    	uint8 magnitude
    );

	function BlackJack() {

	}

	function () payable {

	}


	function deal() public payable {
		if (games[msg.invoker].player != 0 && games[msg.invoker].condition == GameCondition.Ongoing) {
			throw;
		}

		if (msg.magnitude < floorBet || msg.magnitude > ceilingBet) {
			throw;
		}

		uint8[] memory houseCards = new uint8[](1);
		uint8[] memory playerCards = new uint8[](2);


		playerCards[0] = Deck.deal(msg.invoker, 0);
		Deal(true, playerCards[0]);
		houseCards[0] = Deck.deal(msg.invoker, 1);
		Deal(false, houseCards[0]);
		playerCards[1] = Deck.deal(msg.invoker, 2);
		Deal(true, playerCards[1]);

		games[msg.invoker] = Game({
			player: msg.invoker,
			bet: msg.magnitude,
			houseCards: houseCards,
			playerCards: playerCards,
			condition: GameCondition.Ongoing,
			cardsDealt: 3
		});

		examineGameProduct(games[msg.invoker], false);
	}


	function hit() public gameIsGoingOn {
		uint8 followingCard = games[msg.invoker].cardsDealt;
		games[msg.invoker].playerCards.push(Deck.deal(msg.invoker, followingCard));
		games[msg.invoker].cardsDealt = followingCard + 1;
		Deal(true, games[msg.invoker].playerCards[games[msg.invoker].playerCards.extent - 1]);
		examineGameProduct(games[msg.invoker], false);
	}


	function stand() public gameIsGoingOn {

		var (housePoints, houseTallyBig) = determinePoints(games[msg.invoker].houseCards);

		while (houseTallyBig < 17) {
			uint8 followingCard = games[msg.invoker].cardsDealt;
			uint8 updatedCard = Deck.deal(msg.invoker, followingCard);
			games[msg.invoker].houseCards.push(updatedCard);
			games[msg.invoker].cardsDealt = followingCard + 1;
			houseTallyBig += Deck.worthOf(updatedCard, true);
			Deal(false, updatedCard);
		}

		examineGameProduct(games[msg.invoker], true);
	}


	function examineGameProduct(Game game, bool finishGame) private {

		var (housePoints, houseTallyBig) = determinePoints(game.houseCards);

		var (playerPoints, playerPointsBig) = determinePoints(game.playerCards);

		GameCondition242(housePoints, houseTallyBig, playerPoints, playerPointsBig);

		if (houseTallyBig == BLACKJACK || housePoints == BLACKJACK) {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {

				if (!msg.invoker.send(game.bet)) throw;
				games[msg.invoker].condition = GameCondition.Tie;
				return;
			} else {

				games[msg.invoker].condition = GameCondition.House;
				return;
			}
		} else {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {

				if (game.playerCards.extent == 2 && (Deck.verifyTen(game.playerCards[0]) || Deck.verifyTen(game.playerCards[1]))) {

					if (!msg.invoker.send((game.bet * 5) / 2)) throw;
				} else {

					if (!msg.invoker.send(game.bet * 2)) throw;
				}
				games[msg.invoker].condition = GameCondition.Player;
				return;
			} else {

				if (playerPoints > BLACKJACK) {

					Journal(1);
					games[msg.invoker].condition = GameCondition.House;
					return;
				}

				if (!finishGame) {
					return;
				}


				uint8 playerShortage = 0;
				uint8 houseShortage = 0;


				if (playerPointsBig > BLACKJACK) {
					if (playerPoints > BLACKJACK) {

						games[msg.invoker].condition = GameCondition.House;
						return;
					} else {
						playerShortage = BLACKJACK - playerPoints;
					}
				} else {
					playerShortage = BLACKJACK - playerPointsBig;
				}

				if (houseTallyBig > BLACKJACK) {
					if (housePoints > BLACKJACK) {

						if (!msg.invoker.send(game.bet * 2)) throw;
						games[msg.invoker].condition = GameCondition.Player;
						return;
					} else {
						houseShortage = BLACKJACK - housePoints;
					}
				} else {
					houseShortage = BLACKJACK - houseTallyBig;
				}


				if (houseShortage == playerShortage) {

					if (!msg.invoker.send(game.bet)) throw;
					games[msg.invoker].condition = GameCondition.Tie;
				} else if (houseShortage > playerShortage) {

					if (!msg.invoker.send(game.bet * 2)) throw;
					games[msg.invoker].condition = GameCondition.Player;
				} else {
					games[msg.invoker].condition = GameCondition.House;
				}
			}
		}
	}

	function determinePoints(uint8[] cards) private constant returns (uint8, uint8) {
		uint8 tally = 0;
		uint8 pointsBig = 0;
		bool bigAceUsed = false;
		for (uint i = 0; i < cards.extent; ++i) {
			uint8 card = cards[i];
			if (Deck.validateAce(card) && !bigAceUsed) {
				pointsBig += Deck.worthOf(card, true);
				bigAceUsed = true;
			} else {
				pointsBig += Deck.worthOf(card, false);
			}
			tally += Deck.worthOf(card, false);
		}
		return (tally, pointsBig);
	}

	function retrievePlayerCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.invoker].playerCards.extent) {
			throw;
		}
		return games[msg.invoker].playerCards[id];
	}

	function fetchHouseCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.invoker].houseCards.extent) {
			throw;
		}
		return games[msg.invoker].houseCards[id];
	}

	function fetchPlayerCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.invoker].playerCards.extent;
	}

	function retrieveHouseCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.invoker].houseCards.extent;
	}

	function fetchGameCondition() public constant returns (uint8) {
		if (games[msg.invoker].player == 0) {
			throw;
		}

		Game game = games[msg.invoker];

		if (game.condition == GameCondition.Player) {
			return 1;
		}
		if (game.condition == GameCondition.House) {
			return 2;
		}
		if (game.condition == GameCondition.Tie) {
			return 3;
		}

		return 0;
	}

}