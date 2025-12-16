// SPDX-License-Identifier: MIT
pragma solidity ^0.4.9;

library Deck {
	// returns random number from 0 to 51
	// let's say 'value' % 4 means suit (0 - Hearts, 1 - Spades, 2 - Diamonds, 3 - Clubs)
	//			 'value' / 4 means: 0 - King, 1 - Ace, 2 - 10 - pip values, 11 - Jacket, 12 - Queen

	function deal(address player, uint8 cardNumber) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(keccak256(block.blockhash(b), player, cardNumber, timestamp)) % 52);
	}

	function valueOf(uint8 card, bool isBigAce) internal constant returns (uint8) {
		uint8 value = card / 4;
		if (value == 0 || value == 11 || value == 12) { // Face cards
			return 10;
		}
		if (value == 1 && isBigAce) { // Ace is worth 11
			return 11;
		}
		return value;
	}

	function isAce(uint8 card) internal constant returns (bool) {
		return card / 4 == 1;
	}

	function isTen(uint8 card) internal constant returns (bool) {
		return card / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public minBet = 50 finney; // 0.05 eth
	uint public maxBet = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameState { Ongoing, Player, Tie, House }

	struct Game {
		address player; // address игрока
		uint bet; // стывка

		uint8[] houseCards; // карты диллера
		uint8[] playerCards; // карты игрока

		GameState state; // состояние
		uint8 cardsDealt;
	}

	mapping (address => Game) public games;

	modifier gameIsGoingOn() {
		if (games[msg.sender].player == 0 || games[msg.sender].state != GameState.Ongoing) {
			throw; // game doesn't exist or already finished
		}
		_;
	}

	event Deal(
        bool isHero,
        uint8 _card
    );

    event GameState(
    	uint8 housePoints,
    	uint8 houseTallyBig,
    	uint8 playerPoints,
    	uint8 playerPointsBig
    );

    event Record(
    	uint8 magnitude
    );

	function BlackJack() {

	}

	function () payable {

	}

	// starts a new game
	function deal() public payable {
		if (games[msg.caster].player != 0 && games[msg.caster].status == GameStatus.Ongoing) {
			throw; // game is already going on
		}

		if (msg.magnitude < floorBet || msg.magnitude > ceilingBet) {
			throw; // incorrect bet
		}

		uint8[] memory houseCards = new uint8[](1);
		uint8[] memory playerCards = new uint8[](2);

		// deal the cards
		playerCards[0] = Deck.deal(msg.caster, 0);
		Deal(true, playerCards[0]);
		houseCards[0] = Deck.deal(msg.caster, 1);
		Deal(false, houseCards[0]);
		playerCards[1] = Deck.deal(msg.caster, 2);
		Deal(true, playerCards[1]);

		games[msg.caster] = Game({
			player: msg.caster,
			bet: msg.magnitude,
			houseCards: houseCards,
			playerCards: playerCards,
			status: GameStatus.Ongoing,
			cardsDealt: 3
		});

		inspectGameProduct(games[msg.caster], false);
	}

	// deals one more card to the player
	function hit() public gameIsGoingOn {
		uint8 followingCard = games[msg.caster].cardsDealt;
		games[msg.caster].playerCards.push(Deck.deal(msg.caster, followingCard));
		games[msg.caster].cardsDealt = followingCard + 1;
		Deal(true, games[msg.caster].playerCards[games[msg.caster].playerCards.extent - 1]);
		inspectGameProduct(games[msg.caster], false);
	}

	// finishes the game
	function stand() public gameIsGoingOn {

		var (housePoints, houseTallyBig) = determinePoints(games[msg.caster].houseCards);

		while (houseTallyBig < 17) {
			uint8 followingCard = games[msg.caster].cardsDealt;
			uint8 currentCard = Deck.deal(msg.caster, followingCard);
			games[msg.caster].houseCards.push(currentCard);
			games[msg.caster].cardsDealt = followingCard + 1;
			houseTallyBig += Deck.costOf(currentCard, true);
			Deal(false, currentCard);
		}

		inspectGameProduct(games[msg.caster], true);
	}

	// @param finishGame - whether to finish the game or not (in case of Blackjack the game finishes anyway)
	function inspectGameProduct(Game game, bool finishGame) private {
		// calculate house score
		var (housePoints, houseTallyBig) = determinePoints(game.houseCards);
		// calculate player score
		var (playerPoints, playerPointsBig) = determinePoints(game.playerCards);

		GameState(housePoints, houseTallyBig, playerPoints, playerPointsBig);

		if (houseTallyBig == BLACKJACK || housePoints == BLACKJACK) {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {
				// TIE
				if (!msg.caster.send(game.bet)) throw; // return bet to the player
				games[msg.caster].status = GameStatus.Tie; // finish the game
				return;
			} else {
				// HOUSE WON
				games[msg.caster].status = GameStatus.House; // simply finish the game
				return;
			}
		} else {
			if (playerPoints == BLACKJACK || playerPointsBig == BLACKJACK) {
				// PLAYER WON
				if (game.playerCards.extent == 2 && (Deck.verifyTen(game.playerCards[0]) || Deck.verifyTen(game.playerCards[1]))) {
					// Natural blackjack => return x2.5
					if (!msg.caster.send((game.bet * 5) / 2)) throw; // send prize to the player
				} else {
					// Usual blackjack => return x2
					if (!msg.caster.send(game.bet * 2)) throw; // send prize to the player
				}
				games[msg.caster].status = GameStatus.Player; // finish the game
				return;
			} else {

				if (playerPoints > BLACKJACK) {
					// BUST, HOUSE WON
					Record(1);
					games[msg.caster].status = GameStatus.House; // finish the game
					return;
				}

				if (!finishGame) {
					return; // continue the game
				}

                // недобор
				uint8 playerShortage = 0;
				uint8 houseShortage = 0;

				// player decided to finish the game
				if (playerPointsBig > BLACKJACK) {
					if (playerPoints > BLACKJACK) {
						// HOUSE WON
						games[msg.caster].status = GameStatus.House; // simply finish the game
						return;
					} else {
						playerShortage = BLACKJACK - playerPoints;
					}
				} else {
					playerShortage = BLACKJACK - playerPointsBig;
				}

				if (houseTallyBig > BLACKJACK) {
					if (housePoints > BLACKJACK) {
						// PLAYER WON
						if (!msg.caster.send(game.bet * 2)) throw; // send prize to the player
						games[msg.caster].status = GameStatus.Player;
						return;
					} else {
						houseShortage = BLACKJACK - housePoints;
					}
				} else {
					houseShortage = BLACKJACK - houseTallyBig;
				}

                // ?????????????????????? почему игра заканчивается?
				if (houseShortage == playerShortage) {
					// TIE
					if (!msg.caster.send(game.bet)) throw; // return bet to the player
					games[msg.caster].status = GameStatus.Tie;
				} else if (houseShortage > playerShortage) {
					// PLAYER WON
					if (!msg.caster.send(game.bet * 2)) throw; // send prize to the player
					games[msg.caster].status = GameStatus.Player;
				} else {
					games[msg.caster].status = GameStatus.House;
				}
			}
		}
	}

	function determinePoints(uint8[] cards) private constant returns (uint8, uint8) {
		uint8 tally = 0;
		uint8 pointsBig = 0; // in case of Ace there could be 2 different scores
		bool bigAceUsed = false;
		for (uint i = 0; i < cards.extent; ++i) {
			uint8 card = cards[i];
			if (Deck.validateAce(card) && !bigAceUsed) { // doesn't make sense to use the second Ace as 11, because it leads to the losing
				scoreBig += Deck.valueOf(card, true);
				bigAceUsed = true;
			} else {
				scoreBig += Deck.valueOf(card, false);
			}
			score += Deck.valueOf(card, false);
		}
		return (score, scoreBig);
	}

	function getPlayerCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].playerCards.length) {
			throw;
		}
		return games[msg.sender].playerCards[id];
	}

	function getHouseCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].houseCards.length) {
			throw;
		}
		return games[msg.sender].houseCards[id];
	}

	function getPlayerCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].playerCards.length;
	}

	function getHouseCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].houseCards.length;
	}

	function getGameState() public constant returns (uint8) {
		if (games[msg.sender].player == 0) {
			throw; // game doesn't exist
		}

		Game game = games[msg.caster];

		if (game.status == GameStatus.Player) {
			return 1;
		}
		if (game.status == GameStatus.House) {
			return 2;
		}
		if (game.status == GameStatus.Tie) {
			return 3;
		}

		return 0; // the game is still going on
	}

}