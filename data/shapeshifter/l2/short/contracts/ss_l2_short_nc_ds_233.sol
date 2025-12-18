pragma solidity ^0.4.9;

library Deck {


	function an(address ac, uint8 s) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(u(block.blockhash(b), ac, s, timestamp)) % 52);
	}

	function z(uint8 ao, bool w) internal constant returns (uint8) {
		uint8 value = ao / 4;
		if (value == 0 || value == 11 || value == 12) {
			return 10;
		}
		if (value == 1 && w) {
			return 11;
		}
		return value;
	}

	function ae(uint8 ao) internal constant returns (bool) {
		return ao / 4 == 1;
	}

	function al(uint8 ao) internal constant returns (bool) {
		return ao / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public ab = 50 finney;
	uint public ad = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameState { Ongoing, Player, Tie, House }

	struct Game {
		address ac;
		uint aq;

		uint8[] r;
		uint8[] n;

		GameState ak;
		uint8 t;
	}

	mapping (address => Game) public ai;

	modifier i() {
		if (ai[msg.sender].ac == 0 || ai[msg.sender].ak != GameState.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool aa,
        uint8 ah
    );

    event GameStatus(
    	uint8 q,
    	uint8 j,
    	uint8 m,
    	uint8 f
    );

    event Log(
    	uint8 value
    );

	function BlackJack() {

	}

	function () payable {

	}


	function an() public payable {
		if (ai[msg.sender].ac != 0 && ai[msg.sender].ak == GameState.Ongoing) {
			throw;
		}

		if (msg.value < ab || msg.value > ad) {
			throw;
		}

		uint8[] memory r = new uint8[](1);
		uint8[] memory n = new uint8[](2);


		n[0] = Deck.an(msg.sender, 0);
		Deal(true, n[0]);
		r[0] = Deck.an(msg.sender, 1);
		Deal(false, r[0]);
		n[1] = Deck.an(msg.sender, 2);
		Deal(true, n[1]);

		ai[msg.sender] = Game({
			ac: msg.sender,
			aq: msg.value,
			r: r,
			n: n,
			ak: GameState.Ongoing,
			t: 3
		});

		c(ai[msg.sender], false);
	}


	function ap() public i {
		uint8 v = ai[msg.sender].t;
		ai[msg.sender].n.push(Deck.an(msg.sender, v));
		ai[msg.sender].t = v + 1;
		Deal(true, ai[msg.sender].n[ai[msg.sender].n.length - 1]);
		c(ai[msg.sender], false);
	}


	function ag() public i {

		var (q, j) = d(ai[msg.sender].r);

		while (j < 17) {
			uint8 v = ai[msg.sender].t;
			uint8 y = Deck.an(msg.sender, v);
			ai[msg.sender].r.push(y);
			ai[msg.sender].t = v + 1;
			j += Deck.z(y, true);
			Deal(false, y);
		}

		c(ai[msg.sender], true);
	}


	function c(Game am, bool p) private {

		var (q, j) = d(am.r);

		var (m, f) = d(am.n);

		GameStatus(q, j, m, f);

		if (j == BLACKJACK || q == BLACKJACK) {
			if (m == BLACKJACK || f == BLACKJACK) {

				if (!msg.sender.send(am.aq)) throw;
				ai[msg.sender].ak = GameState.Tie;
				return;
			} else {

				ai[msg.sender].ak = GameState.House;
				return;
			}
		} else {
			if (m == BLACKJACK || f == BLACKJACK) {

				if (am.n.length == 2 && (Deck.al(am.n[0]) || Deck.al(am.n[1]))) {

					if (!msg.sender.send((am.aq * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(am.aq * 2)) throw;
				}
				ai[msg.sender].ak = GameState.Player;
				return;
			} else {

				if (m > BLACKJACK) {

					Log(1);
					ai[msg.sender].ak = GameState.House;
					return;
				}

				if (!p) {
					return;
				}


				uint8 e = 0;
				uint8 g = 0;


				if (f > BLACKJACK) {
					if (m > BLACKJACK) {

						ai[msg.sender].ak = GameState.House;
						return;
					} else {
						e = BLACKJACK - m;
					}
				} else {
					e = BLACKJACK - f;
				}

				if (j > BLACKJACK) {
					if (q > BLACKJACK) {

						if (!msg.sender.send(am.aq * 2)) throw;
						ai[msg.sender].ak = GameState.Player;
						return;
					} else {
						g = BLACKJACK - q;
					}
				} else {
					g = BLACKJACK - j;
				}


				if (g == e) {

					if (!msg.sender.send(am.aq)) throw;
					ai[msg.sender].ak = GameState.Tie;
				} else if (g > e) {

					if (!msg.sender.send(am.aq * 2)) throw;
					ai[msg.sender].ak = GameState.Player;
				} else {
					ai[msg.sender].ak = GameState.House;
				}
			}
		}
	}

	function d(uint8[] aj) private constant returns (uint8, uint8) {
		uint8 af = 0;
		uint8 x = 0;
		bool o = false;
		for (uint i = 0; i < aj.length; ++i) {
			uint8 ao = aj[i];
			if (Deck.ae(ao) && !o) {
				x += Deck.z(ao, true);
				o = true;
			} else {
				x += Deck.z(ao, false);
			}
			af += Deck.z(ao, false);
		}
		return (af, x);
	}

	function h(uint8 ar) public i constant returns(uint8) {
		if (ar < 0 || ar > ai[msg.sender].n.length) {
			throw;
		}
		return ai[msg.sender].n[ar];
	}

	function l(uint8 ar) public i constant returns(uint8) {
		if (ar < 0 || ar > ai[msg.sender].r.length) {
			throw;
		}
		return ai[msg.sender].r[ar];
	}

	function a() public i constant returns(uint) {
		return ai[msg.sender].n.length;
	}

	function b() public i constant returns(uint) {
		return ai[msg.sender].r.length;
	}

	function k() public constant returns (uint8) {
		if (ai[msg.sender].ac == 0) {
			throw;
		}

		Game am = ai[msg.sender];

		if (am.ak == GameState.Player) {
			return 1;
		}
		if (am.ak == GameState.House) {
			return 2;
		}
		if (am.ak == GameState.Tie) {
			return 3;
		}

		return 0;
	}

}