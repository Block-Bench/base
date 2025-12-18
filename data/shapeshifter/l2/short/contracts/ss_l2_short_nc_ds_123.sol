pragma solidity ^0.4.16;

contract af {
    address public ad;

    function af() public {
        ad = msg.sender;
    }

    modifier n {
        require(msg.sender == ad);
        _;
    }

    function b(address q) n public {
        ad = q;
    }
}

interface f { function d(address ae, uint256 z, address ab, bytes k) external; }

contract TokenERC20 {

    string public ag;
    string public y;
    uint8 public s = 18;

    uint256 public i;


    mapping (address => uint256) public p;
    mapping (address => mapping (address => uint256)) public l;


    event Transfer(address indexed from, address indexed aj, uint256 value);


    event Approval(address indexed w, address indexed r, uint256 z);

    function TokenERC20(
        string o,
        string j
    ) public {
        ag = o;
        y = j;
    }

    function m(address ae, address ah, uint z) internal {

        require(ah != 0x0);

        require(p[ae] >= z);

        require(p[ah] + z > p[ah]);

        uint c = p[ae] + p[ah];

        p[ae] -= z;

        p[ah] += z;
        emit Transfer(ae, ah, z);

        assert(p[ae] + p[ah] == c);
    }

    function transfer(address ah, uint256 z) public returns (bool u) {
        m(msg.sender, ah, z);
        return true;
    }

    function h(address ae, address ah, uint256 z) public returns (bool u) {
        require(z <= l[ae][msg.sender]);
        l[ae][msg.sender] -= z;
        m(ae, ah, z);
        return true;
    }

    function v(address r, uint256 z) public
        returns (bool u) {
        l[msg.sender][r] = z;
        emit Approval(msg.sender, r, z);
        return true;
    }

    function e(address r, uint256 z, bytes k)
        public
        returns (bool u) {
        f t = f(r);
        if (v(r, z)) {
            t.d(msg.sender, z, this, k);
            return true;
        }
    }

}


contract MyAdvancedToken is af, TokenERC20 {

    mapping (address => bool) public g;


    event FrozenFunds(address ac, bool aa);


    function MyAdvancedToken(
        string o,
        string j
    ) TokenERC20(o, j) public {}


    function m(address ae, address ah, uint z) internal {
        require (ah != 0x0);
        require (p[ae] >= z);
        require (p[ah] + z >= p[ah]);
        require(!g[ae]);
        require(!g[ah]);
        p[ae] -= z;
        p[ah] += z;
        emit Transfer(ae, ah, z);
    }


    function ai() payable public {
        uint x = msg.value;
	p[msg.sender] += x;
        i += x;
        m(address(0x0), msg.sender, x);
    }


    function a() n {
	assert(this.balance == i);
	suicide(ad);
    }
}