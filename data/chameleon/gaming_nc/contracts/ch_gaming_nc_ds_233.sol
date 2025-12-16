pragma solidity ^0.4.9;

library Deck {


	function deal(address player, uint8 cardNumber) internal returns (uint8) {
		uint b = block.number;
		uint adventureTime = block.timestamp;
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
		if (games[msg.sender].player == 0 || games[msg.sender].condition != GameCondition.Ongoing) {
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
		if (games[msg.sender].player != 0 && games[msg.sender].condition == GameCondition.Ongoing) {
			throw;
		}

		if (msg.value < floorBet || msg.value > ceilingBet) {
			throw;
		}

		uint8[] memory houseCards = new uint8[](1);
		uint8[] memory playerCards = new uint8[](2);


		playerCards[0] = Deck.deal(msg.sender, 0);
		Deal(true, playerCards[0]);
		houseCards[0] = Deck.deal(msg.sender, 1);
		Deal(false, houseCards[0]);
		playerCards[1] = Deck.deal(msg.sender, 2);
		Deal(true, playerCards[1]);

		games[msg.sender] = Game({
			player: msg.sender,
			bet: msg.value,
			houseCards: houseCards,
			playerCards: playerCards,
			condition: GameCondition.Ongoing,
			cardsDealt: 3
		});

		examineGameProduct(games[msg.sender], false);
	}


	function hit() public gameIsGoingOn {
		uint8 followingCard = games[msg.sender].cardsDealt;
		games[msg.sender].playerCards.push(Deck.deal(msg.sender, followingCard));
		games[msg.sender].cardsDealt = followingCard + 1;
		Deal(true, games[msg.sender].playerCards[games[msg.sender].playerCards.extent - 1]);
		examineGameProduct(games[msg.sender], false);
	}


	function stand() public gameIsGoingOn {

		var (housePoints, houseTallyBig) = determinePoints(games[msg.sender].houseCards);

		while (houseTallyBig < 17) {
			uint8 followingCard = games[msg.sender].cardsDealt;
			uint8 updatedCard = Deck.deal(msg.sender, followingCard);
			games[msg.sender].houseCards.push(updatedCard);
			games[msg.sender].cardsDealt = followingCard + 1;
			houseTallyBig += Deck.worthOf(updatedCard, true);
			Deal(false, updatedCard);
		}

		examineGameProduct(games[msg.sender], true);
	}


	function examineGameProduct(Game game, bool finishGame) private {

		var (housePoints, houseTallyBig) = determinePoints(game.houseCards);

		var (playerPoints, playerPointsBig) = determinePoints(game.playerCards);

		GameCondition242(housePoints, houseTallyBig, playerPoints, playerPointsBig);

		if (houseTallyBig == BLACKJACK || housePoints == BLACKJACK) {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {

				if (!msg.sender.send(game.bet)) throw;
				games[msg.sender].condition = GameCondition.Tie;
				return;
			} else {

				games[msg.sender].condition = GameCondition.House;
				return;
			}
		} else {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {

				if (game.playerCards.extent == 2 && (Deck.verifyTen(game.playerCards[0]) || Deck.verifyTen(game.playerCards[1]))) {

					if (!msg.sender.send((game.bet * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(game.bet * 2)) throw;
				}
				games[msg.sender].condition = GameCondition.Player;
				return;
			} else {

				if (playerPoints > BLACKJACK) {

					Journal(1);
					games[msg.sender].condition = GameCondition.House;
					return;
				}

				if (!finishGame) {
					return;
				}


				uint8 playerShortage = 0;
				uint8 houseShortage = 0;


				if (playerPointsBig > BLACKJACK) {
					if (playerPoints > BLACKJACK) {

						games[msg.sender].condition = GameCondition.House;
						return;
					} else {
						playerShortage = BLACKJACK - playerPoints;
					}
				} else {
					playerShortage = BLACKJACK - playerPointsBig;
				}

				if (houseTallyBig > BLACKJACK) {
					if (housePoints > BLACKJACK) {

						if (!msg.sender.send(game.bet * 2)) throw;
						games[msg.sender].condition = GameCondition.Player;
						return;
					} else {
						houseShortage = BLACKJACK - housePoints;
					}
				} else {
					houseShortage = BLACKJACK - houseTallyBig;
				}


				if (houseShortage == playerShortage) {

					if (!msg.sender.send(game.bet)) throw;
					games[msg.sender].condition = GameCondition.Tie;
				} else if (houseShortage > playerShortage) {

					if (!msg.sender.send(game.bet * 2)) throw;
					games[msg.sender].condition = GameCondition.Player;
				} else {
					games[msg.sender].condition = GameCondition.House;
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
		if (id < 0 || id > games[msg.sender].playerCards.extent) {
			throw;
		}
		return games[msg.sender].playerCards[id];
	}

	function fetchHouseCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].houseCards.extent) {
			throw;
		}
		return games[msg.sender].houseCards[id];
	}

	function fetchPlayerCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].playerCards.extent;
	}

	function retrieveHouseCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].houseCards.extent;
	}

	function fetchGameCondition() public constant returns (uint8) {
		if (games[msg.sender].player == 0) {
			throw;
		}

		Game game = games[msg.sender];

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