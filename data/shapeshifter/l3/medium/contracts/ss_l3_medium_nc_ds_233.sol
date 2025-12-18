pragma solidity ^0.4.9;

library Deck {


	function _0x8338e2(address _0xe33deb, uint8 _0xe4654d) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(_0x960d39(block.blockhash(b), _0xe33deb, _0xe4654d, timestamp)) % 52);
	}

	function _0x982f08(uint8 _0x4f08d7, bool _0x81a311) internal constant returns (uint8) {
		uint8 value = _0x4f08d7 / 4;
		if (value == 0 || value == 11 || value == 12) {
			return 10;
		}
		if (value == 1 && _0x81a311) {
			return 11;
		}
		return value;
	}

	function _0xe00fce(uint8 _0x4f08d7) internal constant returns (bool) {
		return _0x4f08d7 / 4 == 1;
	}

	function _0x227a8b(uint8 _0x4f08d7) internal constant returns (bool) {
		return _0x4f08d7 / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public _0x3e14c4 = 50 finney;
	uint public _0x3c8b24 = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameState { Ongoing, Player, Tie, House }

	struct Game {
		address _0xe33deb;
		uint _0x5f5a49;

		uint8[] _0x74c40f;
		uint8[] _0x04b39a;

		GameState _0x38b12f;
		uint8 _0x8c98b6;
	}

	mapping (address => Game) public _0x7592b8;

	modifier _0x07c5ed() {
		if (_0x7592b8[msg.sender]._0xe33deb == 0 || _0x7592b8[msg.sender]._0x38b12f != GameState.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool _0x814ab0,
        uint8 _0x983a7c
    );

    event GameStatus(
    	uint8 _0x6effe4,
    	uint8 _0xe7acb1,
    	uint8 _0xb29a6a,
    	uint8 _0xfe9137
    );

    event Log(
    	uint8 value
    );

	function BlackJack() {

	}

	function () payable {

	}


	function _0x8338e2() public payable {
		if (_0x7592b8[msg.sender]._0xe33deb != 0 && _0x7592b8[msg.sender]._0x38b12f == GameState.Ongoing) {
			throw;
		}

		if (msg.value < _0x3e14c4 || msg.value > _0x3c8b24) {
			throw;
		}

		uint8[] memory _0x74c40f = new uint8[](1);
		uint8[] memory _0x04b39a = new uint8[](2);


		_0x04b39a[0] = Deck._0x8338e2(msg.sender, 0);
		Deal(true, _0x04b39a[0]);
		_0x74c40f[0] = Deck._0x8338e2(msg.sender, 1);
		Deal(false, _0x74c40f[0]);
		_0x04b39a[1] = Deck._0x8338e2(msg.sender, 2);
		Deal(true, _0x04b39a[1]);

		_0x7592b8[msg.sender] = Game({
			_0xe33deb: msg.sender,
			_0x5f5a49: msg.value,
			_0x74c40f: _0x74c40f,
			_0x04b39a: _0x04b39a,
			_0x38b12f: GameState.Ongoing,
			_0x8c98b6: 3
		});

		_0x1a0d99(_0x7592b8[msg.sender], false);
	}


	function _0x5f51a8() public _0x07c5ed {
		uint8 _0x0deb6f = _0x7592b8[msg.sender]._0x8c98b6;
		_0x7592b8[msg.sender]._0x04b39a.push(Deck._0x8338e2(msg.sender, _0x0deb6f));
		_0x7592b8[msg.sender]._0x8c98b6 = _0x0deb6f + 1;
		Deal(true, _0x7592b8[msg.sender]._0x04b39a[_0x7592b8[msg.sender]._0x04b39a.length - 1]);
		_0x1a0d99(_0x7592b8[msg.sender], false);
	}


	function _0xe5e539() public _0x07c5ed {

		var (_0x6effe4, _0xe7acb1) = _0x39c296(_0x7592b8[msg.sender]._0x74c40f);

		while (_0xe7acb1 < 17) {
			uint8 _0x0deb6f = _0x7592b8[msg.sender]._0x8c98b6;
			uint8 _0xe7a7a9 = Deck._0x8338e2(msg.sender, _0x0deb6f);
			_0x7592b8[msg.sender]._0x74c40f.push(_0xe7a7a9);
			_0x7592b8[msg.sender]._0x8c98b6 = _0x0deb6f + 1;
			_0xe7acb1 += Deck._0x982f08(_0xe7a7a9, true);
			Deal(false, _0xe7a7a9);
		}

		_0x1a0d99(_0x7592b8[msg.sender], true);
	}


	function _0x1a0d99(Game _0x5ac66f, bool _0x88f52d) private {

		var (_0x6effe4, _0xe7acb1) = _0x39c296(_0x5ac66f._0x74c40f);

		var (_0xb29a6a, _0xfe9137) = _0x39c296(_0x5ac66f._0x04b39a);

		GameStatus(_0x6effe4, _0xe7acb1, _0xb29a6a, _0xfe9137);

		if (_0xe7acb1 == BLACKJACK || _0x6effe4 == BLACKJACK) {
			if (_0xb29a6a == BLACKJACK || _0xfe9137 == BLACKJACK) {

				if (!msg.sender.send(_0x5ac66f._0x5f5a49)) throw;
				_0x7592b8[msg.sender]._0x38b12f = GameState.Tie;
				return;
			} else {

				_0x7592b8[msg.sender]._0x38b12f = GameState.House;
				return;
			}
		} else {
			if (_0xb29a6a == BLACKJACK || _0xfe9137 == BLACKJACK) {

				if (_0x5ac66f._0x04b39a.length == 2 && (Deck._0x227a8b(_0x5ac66f._0x04b39a[0]) || Deck._0x227a8b(_0x5ac66f._0x04b39a[1]))) {

					if (!msg.sender.send((_0x5ac66f._0x5f5a49 * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(_0x5ac66f._0x5f5a49 * 2)) throw;
				}
				_0x7592b8[msg.sender]._0x38b12f = GameState.Player;
				return;
			} else {

				if (_0xb29a6a > BLACKJACK) {

					Log(1);
					_0x7592b8[msg.sender]._0x38b12f = GameState.House;
					return;
				}

				if (!_0x88f52d) {
					return;
				}


				uint8 _0x77a558 = 0;
				uint8 _0x41e9e7 = 0;


				if (_0xfe9137 > BLACKJACK) {
					if (_0xb29a6a > BLACKJACK) {

						_0x7592b8[msg.sender]._0x38b12f = GameState.House;
						return;
					} else {
						_0x77a558 = BLACKJACK - _0xb29a6a;
					}
				} else {
					_0x77a558 = BLACKJACK - _0xfe9137;
				}

				if (_0xe7acb1 > BLACKJACK) {
					if (_0x6effe4 > BLACKJACK) {

						if (!msg.sender.send(_0x5ac66f._0x5f5a49 * 2)) throw;
						_0x7592b8[msg.sender]._0x38b12f = GameState.Player;
						return;
					} else {
						_0x41e9e7 = BLACKJACK - _0x6effe4;
					}
				} else {
					_0x41e9e7 = BLACKJACK - _0xe7acb1;
				}


				if (_0x41e9e7 == _0x77a558) {

					if (!msg.sender.send(_0x5ac66f._0x5f5a49)) throw;
					_0x7592b8[msg.sender]._0x38b12f = GameState.Tie;
				} else if (_0x41e9e7 > _0x77a558) {

					if (!msg.sender.send(_0x5ac66f._0x5f5a49 * 2)) throw;
					_0x7592b8[msg.sender]._0x38b12f = GameState.Player;
				} else {
					_0x7592b8[msg.sender]._0x38b12f = GameState.House;
				}
			}
		}
	}

	function _0x39c296(uint8[] _0x0b3d5a) private constant returns (uint8, uint8) {
		uint8 _0x5a7d47 = 0;
		uint8 _0xa67430 = 0;
		bool _0xfaa346 = false;
		for (uint i = 0; i < _0x0b3d5a.length; ++i) {
			uint8 _0x4f08d7 = _0x0b3d5a[i];
			if (Deck._0xe00fce(_0x4f08d7) && !_0xfaa346) {
				_0xa67430 += Deck._0x982f08(_0x4f08d7, true);
				_0xfaa346 = true;
			} else {
				_0xa67430 += Deck._0x982f08(_0x4f08d7, false);
			}
			_0x5a7d47 += Deck._0x982f08(_0x4f08d7, false);
		}
		return (_0x5a7d47, _0xa67430);
	}

	function _0x7b85ef(uint8 _0xeb35c6) public _0x07c5ed constant returns(uint8) {
		if (_0xeb35c6 < 0 || _0xeb35c6 > _0x7592b8[msg.sender]._0x04b39a.length) {
			throw;
		}
		return _0x7592b8[msg.sender]._0x04b39a[_0xeb35c6];
	}

	function _0xc8629e(uint8 _0xeb35c6) public _0x07c5ed constant returns(uint8) {
		if (_0xeb35c6 < 0 || _0xeb35c6 > _0x7592b8[msg.sender]._0x74c40f.length) {
			throw;
		}
		return _0x7592b8[msg.sender]._0x74c40f[_0xeb35c6];
	}

	function _0x2793d1() public _0x07c5ed constant returns(uint) {
		return _0x7592b8[msg.sender]._0x04b39a.length;
	}

	function _0x393f33() public _0x07c5ed constant returns(uint) {
		return _0x7592b8[msg.sender]._0x74c40f.length;
	}

	function _0xb434b3() public constant returns (uint8) {
		if (_0x7592b8[msg.sender]._0xe33deb == 0) {
			throw;
		}

		Game _0x5ac66f = _0x7592b8[msg.sender];

		if (_0x5ac66f._0x38b12f == GameState.Player) {
			return 1;
		}
		if (_0x5ac66f._0x38b12f == GameState.House) {
			return 2;
		}
		if (_0x5ac66f._0x38b12f == GameState.Tie) {
			return 3;
		}

		return 0;
	}

}