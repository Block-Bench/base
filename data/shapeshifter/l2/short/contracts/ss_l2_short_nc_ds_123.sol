pragma solidity ^0.4.16;

contract ae {
    address public ad;

    function ae() public {
        ad = msg.sender;
    }

    modifier m {
        require(msg.sender == ad);
        _;
    }

    function b(address q) m public {
        ad = q;
    }
}

interface f { function d(address af, uint256 y, address aa, bytes k) external; }

contract TokenERC20 {

    string public ag;
    string public w;
    uint8 public s = 18;

    uint256 public i;


    mapping (address => uint256) public n;
    mapping (address => mapping (address => uint256)) public p;


    event Transfer(address indexed from, address indexed aj, uint256 value);


    event Approval(address indexed ac, address indexed r, uint256 y);

    function TokenERC20(
        string o,
        string j
    ) public {
        ag = o;
        w = j;
    }

    function l(address af, address ah, uint y) internal {

        require(ah != 0x0);

        require(n[af] >= y);

        require(n[ah] + y > n[ah]);

        uint c = n[af] + n[ah];

        n[af] -= y;

        n[ah] += y;
        emit Transfer(af, ah, y);

        assert(n[af] + n[ah] == c);
    }

    function transfer(address ah, uint256 y) public returns (bool t) {
        l(msg.sender, ah, y);
        return true;
    }

    function h(address af, address ah, uint256 y) public returns (bool t) {
        require(y <= p[af][msg.sender]);
        p[af][msg.sender] -= y;
        l(af, ah, y);
        return true;
    }

    function v(address r, uint256 y) public
        returns (bool t) {
        p[msg.sender][r] = y;
        emit Approval(msg.sender, r, y);
        return true;
    }

    function e(address r, uint256 y, bytes k)
        public
        returns (bool t) {
        f u = f(r);
        if (v(r, y)) {
            u.d(msg.sender, y, this, k);
            return true;
        }
    }

}


contract MyAdvancedToken is ae, TokenERC20 {

    mapping (address => bool) public g;


    event FrozenFunds(address ab, bool x);


    function MyAdvancedToken(
        string o,
        string j
    ) TokenERC20(o, j) public {}


    function l(address af, address ah, uint y) internal {
        require (ah != 0x0);
        require (n[af] >= y);
        require (n[ah] + y >= n[ah]);
        require(!g[af]);
        require(!g[ah]);
        n[af] -= y;
        n[ah] += y;
        emit Transfer(af, ah, y);
    }


    function ai() payable public {
        uint z = msg.value;
	n[msg.sender] += z;
        i += z;
        l(address(0x0), msg.sender, z);
    }


    function a() m {
	assert(this.balance == i);
	suicide(ad);
    }
}