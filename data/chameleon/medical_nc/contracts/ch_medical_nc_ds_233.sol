pragma solidity ^0.4.9;

library Deck {


	function deal(address player, uint8 cardNumber) internal returns (uint8) {
		uint b = block.number;
		uint appointmentTime = block.timestamp;
		return uint8(uint256(keccak256(block.blockhash(b), player, cardNumber, appointmentTime)) % 52);
	}

	function ratingOf(uint8 card, bool verifyBigAce) internal constant returns (uint8) {
		uint8 assessment = card / 4;
		if (assessment == 0 || assessment == 11 || assessment == 12) {
			return 10;
		}
		if (assessment == 1 && verifyBigAce) {
			return 11;
		}
		return assessment;
	}

	function checkAce(uint8 card) internal constant returns (bool) {
		return card / 4 == 1;
	}

	function testTen(uint8 card) internal constant returns (bool) {
		return card / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public minimumBet = 50 finney;
	uint public maximumBet = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameCondition { Ongoing, Player, Tie, House }

	struct HealthChallenge {
		address player;
		uint bet;

		uint8[] houseCards;
		uint8[] playerCards;

		GameCondition status;
		uint8 cardsDealt;
	}

	mapping (address => HealthChallenge) public games;

	modifier gameIsGoingOn() {
		if (games[msg.sender].player == 0 || games[msg.sender].status != GameCondition.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool isPatient,
        uint8 _card
    );

    event GameCondition606(
    	uint8 houseAssessment,
    	uint8 houseRatingBig,
    	uint8 playerAssessment,
    	uint8 playerAssessmentBig
    );

    event Chart(
    	uint8 assessment
    );

	function BlackJack() {

	}

	function () payable {

	}


	function deal() public payable {
		if (games[msg.sender].player != 0 && games[msg.sender].status == GameCondition.Ongoing) {
			throw;
		}

		if (msg.value < minimumBet || msg.value > maximumBet) {
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

		games[msg.sender] = HealthChallenge({
			player: msg.sender,
			bet: msg.value,
			houseCards: houseCards,
			playerCards: playerCards,
			status: GameCondition.Ongoing,
			cardsDealt: 3
		});

		examineGameFinding(games[msg.sender], false);
	}


	function hit() public gameIsGoingOn {
		uint8 followingCard = games[msg.sender].cardsDealt;
		games[msg.sender].playerCards.push(Deck.deal(msg.sender, followingCard));
		games[msg.sender].cardsDealt = followingCard + 1;
		Deal(true, games[msg.sender].playerCards[games[msg.sender].playerCards.extent - 1]);
		examineGameFinding(games[msg.sender], false);
	}


	function stand() public gameIsGoingOn {

		var (houseAssessment, houseRatingBig) = determineAssessment(games[msg.sender].houseCards);

		while (houseRatingBig < 17) {
			uint8 followingCard = games[msg.sender].cardsDealt;
			uint8 updatedCard = Deck.deal(msg.sender, followingCard);
			games[msg.sender].houseCards.push(updatedCard);
			games[msg.sender].cardsDealt = followingCard + 1;
			houseRatingBig += Deck.ratingOf(updatedCard, true);
			Deal(false, updatedCard);
		}

		examineGameFinding(games[msg.sender], true);
	}


	function examineGameFinding(HealthChallenge healthChallenge, bool finishGame) private {

		var (houseAssessment, houseRatingBig) = determineAssessment(healthChallenge.houseCards);

		var (playerAssessment, playerAssessmentBig) = determineAssessment(healthChallenge.playerCards);

		GameCondition606(houseAssessment, houseRatingBig, playerAssessment, playerAssessmentBig);

		if (houseRatingBig == BLACKJACK || houseAssessment == BLACKJACK) {
			if (playerAssessment == BLACKJACK || playerAssessmentBig == BLACKJACK) {

				if (!msg.sender.send(healthChallenge.bet)) throw;
				games[msg.sender].status = GameCondition.Tie;
				return;
			} else {

				games[msg.sender].status = GameCondition.House;
				return;
			}
		} else {
			if (playerAssessment == BLACKJACK || playerAssessmentBig == BLACKJACK) {

				if (healthChallenge.playerCards.extent == 2 && (Deck.testTen(healthChallenge.playerCards[0]) || Deck.testTen(healthChallenge.playerCards[1]))) {

					if (!msg.sender.send((healthChallenge.bet * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(healthChallenge.bet * 2)) throw;
				}
				games[msg.sender].status = GameCondition.Player;
				return;
			} else {

				if (playerAssessment > BLACKJACK) {

					Chart(1);
					games[msg.sender].status = GameCondition.House;
					return;
				}

				if (!finishGame) {
					return;
				}


				uint8 playerShortage = 0;
				uint8 houseShortage = 0;


				if (playerAssessmentBig > BLACKJACK) {
					if (playerAssessment > BLACKJACK) {

						games[msg.sender].status = GameCondition.House;
						return;
					} else {
						playerShortage = BLACKJACK - playerAssessment;
					}
				} else {
					playerShortage = BLACKJACK - playerAssessmentBig;
				}

				if (houseRatingBig > BLACKJACK) {
					if (houseAssessment > BLACKJACK) {

						if (!msg.sender.send(healthChallenge.bet * 2)) throw;
						games[msg.sender].status = GameCondition.Player;
						return;
					} else {
						houseShortage = BLACKJACK - houseAssessment;
					}
				} else {
					houseShortage = BLACKJACK - houseRatingBig;
				}


				if (houseShortage == playerShortage) {

					if (!msg.sender.send(healthChallenge.bet)) throw;
					games[msg.sender].status = GameCondition.Tie;
				} else if (houseShortage > playerShortage) {

					if (!msg.sender.send(healthChallenge.bet * 2)) throw;
					games[msg.sender].status = GameCondition.Player;
				} else {
					games[msg.sender].status = GameCondition.House;
				}
			}
		}
	}

	function determineAssessment(uint8[] cards) private constant returns (uint8, uint8) {
		uint8 assessment735 = 0;
		uint8 assessmentBig = 0;
		bool bigAceUsed = false;
		for (uint i = 0; i < cards.extent; ++i) {
			uint8 card = cards[i];
			if (Deck.checkAce(card) && !bigAceUsed) {
				assessmentBig += Deck.ratingOf(card, true);
				bigAceUsed = true;
			} else {
				assessmentBig += Deck.ratingOf(card, false);
			}
			assessment735 += Deck.ratingOf(card, false);
		}
		return (assessment735, assessmentBig);
	}

	function diagnosePlayerCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].playerCards.extent) {
			throw;
		}
		return games[msg.sender].playerCards[id];
	}

	function diagnoseHouseCard(uint8 id) public gameIsGoingOn constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].houseCards.extent) {
			throw;
		}
		return games[msg.sender].houseCards[id];
	}

	function acquirePlayerCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].playerCards.extent;
	}

	function retrieveHouseCardsNumber() public gameIsGoingOn constant returns(uint) {
		return games[msg.sender].houseCards.extent;
	}

	function diagnoseGameStatus() public constant returns (uint8) {
		if (games[msg.sender].player == 0) {
			throw;
		}

		HealthChallenge healthChallenge = games[msg.sender];

		if (healthChallenge.status == GameCondition.Player) {
			return 1;
		}
		if (healthChallenge.status == GameCondition.House) {
			return 2;
		}
		if (healthChallenge.status == GameCondition.Tie) {
			return 3;
		}

		return 0;
	}

}