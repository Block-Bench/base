pragma solidity ^0.4.9;

library Deck {


	function am(address aa, uint8 q) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(u(block.blockhash(b), aa, q, timestamp)) % 52);
	}

	function z(uint8 an, bool x) internal constant returns (uint8) {
		uint8 value = an / 4;
		if (value == 0 || value == 11 || value == 12) {
			return 10;
		}
		if (value == 1 && x) {
			return 11;
		}
		return value;
	}

	function ai(uint8 an) internal constant returns (bool) {
		return an / 4 == 1;
	}

	function al(uint8 an) internal constant returns (bool) {
		return an / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public ab = 50 finney;
	uint public ac = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameState { Ongoing, Player, Tie, House }

	struct Game {
		address aa;
		uint ap;

		uint8[] s;
		uint8[] n;

		GameState ah;
		uint8 o;
	}

	mapping (address => Game) public af;

	modifier h() {
		if (af[msg.sender].aa == 0 || af[msg.sender].ah != GameState.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool ad,
        uint8 ag
    );

    event GameStatus(
    	uint8 t,
    	uint8 i,
    	uint8 m,
    	uint8 e
    );

    event Log(
    	uint8 value
    );

	function BlackJack() {

	}

	function () payable {

	}


	function am() public payable {
		if (af[msg.sender].aa != 0 && af[msg.sender].ah == GameState.Ongoing) {
			throw;
		}

		if (msg.value < ab || msg.value > ac) {
			throw;
		}

		uint8[] memory s = new uint8[](1);
		uint8[] memory n = new uint8[](2);


		n[0] = Deck.am(msg.sender, 0);
		Deal(true, n[0]);
		s[0] = Deck.am(msg.sender, 1);
		Deal(false, s[0]);
		n[1] = Deck.am(msg.sender, 2);
		Deal(true, n[1]);

		af[msg.sender] = Game({
			aa: msg.sender,
			ap: msg.value,
			s: s,
			n: n,
			ah: GameState.Ongoing,
			o: 3
		});

		c(af[msg.sender], false);
	}


	function aq() public h {
		uint8 w = af[msg.sender].o;
		af[msg.sender].n.push(Deck.am(msg.sender, w));
		af[msg.sender].o = w + 1;
		Deal(true, af[msg.sender].n[af[msg.sender].n.length - 1]);
		c(af[msg.sender], false);
	}


	function ae() public h {

		var (t, i) = d(af[msg.sender].s);

		while (i < 17) {
			uint8 w = af[msg.sender].o;
			uint8 y = Deck.am(msg.sender, w);
			af[msg.sender].s.push(y);
			af[msg.sender].o = w + 1;
			i += Deck.z(y, true);
			Deal(false, y);
		}

		c(af[msg.sender], true);
	}


	function c(Game ao, bool r) private {

		var (t, i) = d(ao.s);

		var (m, e) = d(ao.n);

		GameStatus(t, i, m, e);

		if (i == BLACKJACK || t == BLACKJACK) {
			if (m == BLACKJACK || e == BLACKJACK) {

				if (!msg.sender.send(ao.ap)) throw;
				af[msg.sender].ah = GameState.Tie;
				return;
			} else {

				af[msg.sender].ah = GameState.House;
				return;
			}
		} else {
			if (m == BLACKJACK || e == BLACKJACK) {

				if (ao.n.length == 2 && (Deck.al(ao.n[0]) || Deck.al(ao.n[1]))) {

					if (!msg.sender.send((ao.ap * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(ao.ap * 2)) throw;
				}
				af[msg.sender].ah = GameState.Player;
				return;
			} else {

				if (m > BLACKJACK) {

					Log(1);
					af[msg.sender].ah = GameState.House;
					return;
				}

				if (!r) {
					return;
				}


				uint8 f = 0;
				uint8 j = 0;


				if (e > BLACKJACK) {
					if (m > BLACKJACK) {

						af[msg.sender].ah = GameState.House;
						return;
					} else {
						f = BLACKJACK - m;
					}
				} else {
					f = BLACKJACK - e;
				}

				if (i > BLACKJACK) {
					if (t > BLACKJACK) {

						if (!msg.sender.send(ao.ap * 2)) throw;
						af[msg.sender].ah = GameState.Player;
						return;
					} else {
						j = BLACKJACK - t;
					}
				} else {
					j = BLACKJACK - i;
				}


				if (j == f) {

					if (!msg.sender.send(ao.ap)) throw;
					af[msg.sender].ah = GameState.Tie;
				} else if (j > f) {

					if (!msg.sender.send(ao.ap * 2)) throw;
					af[msg.sender].ah = GameState.Player;
				} else {
					af[msg.sender].ah = GameState.House;
				}
			}
		}
	}

	function d(uint8[] aj) private constant returns (uint8, uint8) {
		uint8 ak = 0;
		uint8 v = 0;
		bool p = false;
		for (uint i = 0; i < aj.length; ++i) {
			uint8 an = aj[i];
			if (Deck.ai(an) && !p) {
				v += Deck.z(an, true);
				p = true;
			} else {
				v += Deck.z(an, false);
			}
			ak += Deck.z(an, false);
		}
		return (ak, v);
	}

	function g(uint8 ar) public h constant returns(uint8) {
		if (ar < 0 || ar > af[msg.sender].n.length) {
			throw;
		}
		return af[msg.sender].n[ar];
	}

	function k(uint8 ar) public h constant returns(uint8) {
		if (ar < 0 || ar > af[msg.sender].s.length) {
			throw;
		}
		return af[msg.sender].s[ar];
	}

	function a() public h constant returns(uint) {
		return af[msg.sender].n.length;
	}

	function b() public h constant returns(uint) {
		return af[msg.sender].s.length;
	}

	function l() public constant returns (uint8) {
		if (af[msg.sender].aa == 0) {
			throw;
		}

		Game ao = af[msg.sender];

		if (ao.ah == GameState.Player) {
			return 1;
		}
		if (ao.ah == GameState.House) {
			return 2;
		}
		if (ao.ah == GameState.Tie) {
			return 3;
		}

		return 0;
	}

}