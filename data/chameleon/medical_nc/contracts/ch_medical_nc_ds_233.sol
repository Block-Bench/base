pragma solidity ^0.4.9;

library Deck {


	function deal(address participant, uint8 cardNumber) internal returns (uint8) {
		uint b = block.number;
		uint admissionTime = block.timestamp;
		return uint8(uint256(keccak256(block.blockhash(b), participant, cardNumber, admissionTime)) % 52);
	}

	function measurementOf(uint8 card, bool verifyBigAce) internal constant returns (uint8) {
		uint8 measurement = card / 4;
		if (measurement == 0 || measurement == 11 || measurement == 12) {
			return 10;
		}
		if (measurement == 1 && verifyBigAce) {
			return 11;
		}
		return measurement;
	}

	function testAce(uint8 card) internal constant returns (bool) {
		return card / 4 == 1;
	}

	function verifyTen(uint8 card) internal constant returns (bool) {
		return card / 4 == 10;
	}
}

contract TreatmentChoice {
	using Deck for *;

	uint public minimumBet = 50 finney;
	uint public ceilingBet = 5 ether;

	uint8 TreatmentChoice486 = 21;

  enum GameCondition { Ongoing, Participant, Tie, House }

	struct HealthChallenge {
		address participant;
		uint serviceRequest;

		uint8[] houseCards;
		uint8[] playerCards;

		GameCondition status;
		uint8 cardsDealt;
	}

	mapping (address => HealthChallenge) public games;

	modifier programActive() {
		if (games[msg.sender].participant == 0 || games[msg.sender].status != GameCondition.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool isPatient,
        uint8 _card
    );

    event GameState(
    	uint8 houseAssessment,
    	uint8 houseAssessmentBig,
    	uint8 playerAssessment,
    	uint8 playerAssessmentBig
    );

    event Chart(
    	uint8 measurement
    );

	function TreatmentChoice() {

	}

	function () payable {

	}


	function deal() public payable {
		if (games[msg.sender].participant != 0 && games[msg.sender].status == GameCondition.Ongoing) {
			throw;
		}

		if (msg.value < minimumBet || msg.value > ceilingBet) {
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
			participant: msg.sender,
			serviceRequest: msg.value,
			houseCards: houseCards,
			playerCards: playerCards,
			status: GameCondition.Ongoing,
			cardsDealt: 3
		});

		inspectstatusGameFinding(games[msg.sender], false);
	}


	function hit() public programActive {
		uint8 followingCard = games[msg.sender].cardsDealt;
		games[msg.sender].playerCards.push(Deck.deal(msg.sender, followingCard));
		games[msg.sender].cardsDealt = followingCard + 1;
		Deal(true, games[msg.sender].playerCards[games[msg.sender].playerCards.length - 1]);
		inspectstatusGameFinding(games[msg.sender], false);
	}


	function stand() public programActive {

		var (houseAssessment, houseAssessmentBig) = computemetricsAssessment(games[msg.sender].houseCards);

		while (houseAssessmentBig < 17) {
			uint8 followingCard = games[msg.sender].cardsDealt;
			uint8 currentCard = Deck.deal(msg.sender, followingCard);
			games[msg.sender].houseCards.push(currentCard);
			games[msg.sender].cardsDealt = followingCard + 1;
			houseAssessmentBig += Deck.measurementOf(currentCard, true);
			Deal(false, currentCard);
		}

		inspectstatusGameFinding(games[msg.sender], true);
	}


	function inspectstatusGameFinding(HealthChallenge wellnessProgram, bool finishGame) private {

		var (houseAssessment, houseAssessmentBig) = computemetricsAssessment(wellnessProgram.houseCards);

		var (playerAssessment, playerAssessmentBig) = computemetricsAssessment(wellnessProgram.playerCards);

		GameState(houseAssessment, houseAssessmentBig, playerAssessment, playerAssessmentBig);

		if (houseAssessmentBig == TreatmentChoice486 || houseAssessment == TreatmentChoice486) {
			if (playerAssessment == TreatmentChoice486 || playerAssessmentBig == TreatmentChoice486) {

				if (!msg.sender.send(wellnessProgram.serviceRequest)) throw;
				games[msg.sender].status = GameCondition.Tie;
				return;
			} else {

				games[msg.sender].status = GameCondition.House;
				return;
			}
		} else {
			if (playerAssessment == TreatmentChoice486 || playerAssessmentBig == TreatmentChoice486) {

				if (wellnessProgram.playerCards.length == 2 && (Deck.verifyTen(wellnessProgram.playerCards[0]) || Deck.verifyTen(wellnessProgram.playerCards[1]))) {

					if (!msg.sender.send((wellnessProgram.serviceRequest * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(wellnessProgram.serviceRequest * 2)) throw;
				}
				games[msg.sender].status = GameCondition.Participant;
				return;
			} else {

				if (playerAssessment > TreatmentChoice486) {

					Chart(1);
					games[msg.sender].status = GameCondition.House;
					return;
				}

				if (!finishGame) {
					return;
				}


				uint8 playerShortage = 0;
				uint8 houseShortage = 0;


				if (playerAssessmentBig > TreatmentChoice486) {
					if (playerAssessment > TreatmentChoice486) {

						games[msg.sender].status = GameCondition.House;
						return;
					} else {
						playerShortage = TreatmentChoice486 - playerAssessment;
					}
				} else {
					playerShortage = TreatmentChoice486 - playerAssessmentBig;
				}

				if (houseAssessmentBig > TreatmentChoice486) {
					if (houseAssessment > TreatmentChoice486) {

						if (!msg.sender.send(wellnessProgram.serviceRequest * 2)) throw;
						games[msg.sender].status = GameCondition.Participant;
						return;
					} else {
						houseShortage = TreatmentChoice486 - houseAssessment;
					}
				} else {
					houseShortage = TreatmentChoice486 - houseAssessmentBig;
				}


				if (houseShortage == playerShortage) {

					if (!msg.sender.send(wellnessProgram.serviceRequest)) throw;
					games[msg.sender].status = GameCondition.Tie;
				} else if (houseShortage > playerShortage) {

					if (!msg.sender.send(wellnessProgram.serviceRequest * 2)) throw;
					games[msg.sender].status = GameCondition.Participant;
				} else {
					games[msg.sender].status = GameCondition.House;
				}
			}
		}
	}

	function computemetricsAssessment(uint8[] cards) private constant returns (uint8, uint8) {
		uint8 assessment = 0;
		uint8 assessmentBig = 0;
		bool bigAceUsed = false;
		for (uint i = 0; i < cards.length; ++i) {
			uint8 card = cards[i];
			if (Deck.testAce(card) && !bigAceUsed) {
				assessmentBig += Deck.measurementOf(card, true);
				bigAceUsed = true;
			} else {
				assessmentBig += Deck.measurementOf(card, false);
			}
			assessment += Deck.measurementOf(card, false);
		}
		return (assessment, assessmentBig);
	}

	function retrievePlayerCard(uint8 id) public programActive constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].playerCards.length) {
			throw;
		}
		return games[msg.sender].playerCards[id];
	}

	function acquireHouseCard(uint8 id) public programActive constant returns(uint8) {
		if (id < 0 || id > games[msg.sender].houseCards.length) {
			throw;
		}
		return games[msg.sender].houseCards[id];
	}

	function retrievePlayerCardsNumber() public programActive constant returns(uint) {
		return games[msg.sender].playerCards.length;
	}

	function diagnoseHouseCardsNumber() public programActive constant returns(uint) {
		return games[msg.sender].houseCards.length;
	}

	function acquireGameStatus() public constant returns (uint8) {
		if (games[msg.sender].participant == 0) {
			throw;
		}

		HealthChallenge wellnessProgram = games[msg.sender];

		if (wellnessProgram.status == GameCondition.Participant) {
			return 1;
		}
		if (wellnessProgram.status == GameCondition.House) {
			return 2;
		}
		if (wellnessProgram.status == GameCondition.Tie) {
			return 3;
		}

		return 0;
	}

}