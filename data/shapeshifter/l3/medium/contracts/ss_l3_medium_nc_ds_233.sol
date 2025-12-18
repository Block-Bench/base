pragma solidity ^0.4.9;

library Deck {


	function _0xe4a479(address _0x7e6b24, uint8 _0x7b7d98) internal returns (uint8) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint8(uint256(_0x955437(block.blockhash(b), _0x7e6b24, _0x7b7d98, timestamp)) % 52);
	}

	function _0xab7b95(uint8 _0xaec45a, bool _0x6ca163) internal constant returns (uint8) {
		uint8 value = _0xaec45a / 4;
		if (value == 0 || value == 11 || value == 12) {
			return 10;
		}
		if (value == 1 && _0x6ca163) {
			return 11;
		}
		return value;
	}

	function _0x648e7d(uint8 _0xaec45a) internal constant returns (bool) {
		return _0xaec45a / 4 == 1;
	}

	function _0x0884fa(uint8 _0xaec45a) internal constant returns (bool) {
		return _0xaec45a / 4 == 10;
	}
}

contract BlackJack {
	using Deck for *;

	uint public _0xf1b8e6 = 50 finney;
	uint public _0x4e94f4 = 5 ether;

	uint8 BLACKJACK = 21;

  enum GameState { Ongoing, Player, Tie, House }

	struct Game {
		address _0x7e6b24;
		uint _0x544f00;

		uint8[] _0xa0fc6f;
		uint8[] _0x27108b;

		GameState _0xa0bb11;
		uint8 _0xe5ed6a;
	}

	mapping (address => Game) public _0x698799;

	modifier _0x3d4696() {
		if (_0x698799[msg.sender]._0x7e6b24 == 0 || _0x698799[msg.sender]._0xa0bb11 != GameState.Ongoing) {
			throw;
		}
		_;
	}

	event Deal(
        bool _0xa8fdc8,
        uint8 _0x6330ad
    );

    event GameStatus(
    	uint8 _0x819bc8,
    	uint8 _0xec1a63,
    	uint8 _0x8cf818,
    	uint8 _0xcd2fe9
    );

    event Log(
    	uint8 value
    );

	function BlackJack() {

	}

	function () payable {

	}


	function _0xe4a479() public payable {
		if (_0x698799[msg.sender]._0x7e6b24 != 0 && _0x698799[msg.sender]._0xa0bb11 == GameState.Ongoing) {
			throw;
		}

		if (msg.value < _0xf1b8e6 || msg.value > _0x4e94f4) {
			throw;
		}

		uint8[] memory _0xa0fc6f = new uint8[](1);
		uint8[] memory _0x27108b = new uint8[](2);


		_0x27108b[0] = Deck._0xe4a479(msg.sender, 0);
		Deal(true, _0x27108b[0]);
		_0xa0fc6f[0] = Deck._0xe4a479(msg.sender, 1);
		Deal(false, _0xa0fc6f[0]);
		_0x27108b[1] = Deck._0xe4a479(msg.sender, 2);
		Deal(true, _0x27108b[1]);

		_0x698799[msg.sender] = Game({
			_0x7e6b24: msg.sender,
			_0x544f00: msg.value,
			_0xa0fc6f: _0xa0fc6f,
			_0x27108b: _0x27108b,
			_0xa0bb11: GameState.Ongoing,
			_0xe5ed6a: 3
		});

		_0xeb061d(_0x698799[msg.sender], false);
	}


	function _0x3ed6fa() public _0x3d4696 {
		uint8 _0x77b621 = _0x698799[msg.sender]._0xe5ed6a;
		_0x698799[msg.sender]._0x27108b.push(Deck._0xe4a479(msg.sender, _0x77b621));
		_0x698799[msg.sender]._0xe5ed6a = _0x77b621 + 1;
		Deal(true, _0x698799[msg.sender]._0x27108b[_0x698799[msg.sender]._0x27108b.length - 1]);
		_0xeb061d(_0x698799[msg.sender], false);
	}


	function _0xaa30ad() public _0x3d4696 {

		var (_0x819bc8, _0xec1a63) = _0xa64bb9(_0x698799[msg.sender]._0xa0fc6f);

		while (_0xec1a63 < 17) {
			uint8 _0x77b621 = _0x698799[msg.sender]._0xe5ed6a;
			uint8 _0xb55b35 = Deck._0xe4a479(msg.sender, _0x77b621);
			_0x698799[msg.sender]._0xa0fc6f.push(_0xb55b35);
			_0x698799[msg.sender]._0xe5ed6a = _0x77b621 + 1;
			_0xec1a63 += Deck._0xab7b95(_0xb55b35, true);
			Deal(false, _0xb55b35);
		}

		_0xeb061d(_0x698799[msg.sender], true);
	}


	function _0xeb061d(Game _0x38a3ac, bool _0xaefd9e) private {

		var (_0x819bc8, _0xec1a63) = _0xa64bb9(_0x38a3ac._0xa0fc6f);

		var (_0x8cf818, _0xcd2fe9) = _0xa64bb9(_0x38a3ac._0x27108b);

		GameStatus(_0x819bc8, _0xec1a63, _0x8cf818, _0xcd2fe9);

		if (_0xec1a63 == BLACKJACK || _0x819bc8 == BLACKJACK) {
			if (_0x8cf818 == BLACKJACK || _0xcd2fe9 == BLACKJACK) {

				if (!msg.sender.send(_0x38a3ac._0x544f00)) throw;
				_0x698799[msg.sender]._0xa0bb11 = GameState.Tie;
				return;
			} else {

				_0x698799[msg.sender]._0xa0bb11 = GameState.House;
				return;
			}
		} else {
			if (_0x8cf818 == BLACKJACK || _0xcd2fe9 == BLACKJACK) {

				if (_0x38a3ac._0x27108b.length == 2 && (Deck._0x0884fa(_0x38a3ac._0x27108b[0]) || Deck._0x0884fa(_0x38a3ac._0x27108b[1]))) {

					if (!msg.sender.send((_0x38a3ac._0x544f00 * 5) / 2)) throw;
				} else {

					if (!msg.sender.send(_0x38a3ac._0x544f00 * 2)) throw;
				}
				_0x698799[msg.sender]._0xa0bb11 = GameState.Player;
				return;
			} else {

				if (_0x8cf818 > BLACKJACK) {

					Log(1);
					_0x698799[msg.sender]._0xa0bb11 = GameState.House;
					return;
				}

				if (!_0xaefd9e) {
					return;
				}


				uint8 _0x4bf1f9 = 0;
				uint8 _0x9c9c05 = 0;


				if (_0xcd2fe9 > BLACKJACK) {
					if (_0x8cf818 > BLACKJACK) {

						_0x698799[msg.sender]._0xa0bb11 = GameState.House;
						return;
					} else {
						_0x4bf1f9 = BLACKJACK - _0x8cf818;
					}
				} else {
					_0x4bf1f9 = BLACKJACK - _0xcd2fe9;
				}

				if (_0xec1a63 > BLACKJACK) {
					if (_0x819bc8 > BLACKJACK) {

						if (!msg.sender.send(_0x38a3ac._0x544f00 * 2)) throw;
						_0x698799[msg.sender]._0xa0bb11 = GameState.Player;
						return;
					} else {
						_0x9c9c05 = BLACKJACK - _0x819bc8;
					}
				} else {
					_0x9c9c05 = BLACKJACK - _0xec1a63;
				}


				if (_0x9c9c05 == _0x4bf1f9) {

					if (!msg.sender.send(_0x38a3ac._0x544f00)) throw;
					_0x698799[msg.sender]._0xa0bb11 = GameState.Tie;
				} else if (_0x9c9c05 > _0x4bf1f9) {

					if (!msg.sender.send(_0x38a3ac._0x544f00 * 2)) throw;
					_0x698799[msg.sender]._0xa0bb11 = GameState.Player;
				} else {
					_0x698799[msg.sender]._0xa0bb11 = GameState.House;
				}
			}
		}
	}

	function _0xa64bb9(uint8[] _0xace200) private constant returns (uint8, uint8) {
		uint8 _0x75de47 = 0;
		uint8 _0xf5b577 = 0;
		bool _0x542782 = false;
		for (uint i = 0; i < _0xace200.length; ++i) {
			uint8 _0xaec45a = _0xace200[i];
			if (Deck._0x648e7d(_0xaec45a) && !_0x542782) {
				_0xf5b577 += Deck._0xab7b95(_0xaec45a, true);
    if (block.timestamp > 0) { _0x542782 = true; }
			} else {
				_0xf5b577 += Deck._0xab7b95(_0xaec45a, false);
			}
			_0x75de47 += Deck._0xab7b95(_0xaec45a, false);
		}
		return (_0x75de47, _0xf5b577);
	}

	function _0x2a0bf2(uint8 _0x4b51ad) public _0x3d4696 constant returns(uint8) {
		if (_0x4b51ad < 0 || _0x4b51ad > _0x698799[msg.sender]._0x27108b.length) {
			throw;
		}
		return _0x698799[msg.sender]._0x27108b[_0x4b51ad];
	}

	function _0x126a38(uint8 _0x4b51ad) public _0x3d4696 constant returns(uint8) {
		if (_0x4b51ad < 0 || _0x4b51ad > _0x698799[msg.sender]._0xa0fc6f.length) {
			throw;
		}
		return _0x698799[msg.sender]._0xa0fc6f[_0x4b51ad];
	}

	function _0x705630() public _0x3d4696 constant returns(uint) {
		return _0x698799[msg.sender]._0x27108b.length;
	}

	function _0x31ac9c() public _0x3d4696 constant returns(uint) {
		return _0x698799[msg.sender]._0xa0fc6f.length;
	}

	function _0x600a2f() public constant returns (uint8) {
		if (_0x698799[msg.sender]._0x7e6b24 == 0) {
			throw;
		}

		Game _0x38a3ac = _0x698799[msg.sender];

		if (_0x38a3ac._0xa0bb11 == GameState.Player) {
			return 1;
		}
		if (_0x38a3ac._0xa0bb11 == GameState.House) {
			return 2;
		}
		if (_0x38a3ac._0xa0bb11 == GameState.Tie) {
			return 3;
		}

		return 0;
	}

}