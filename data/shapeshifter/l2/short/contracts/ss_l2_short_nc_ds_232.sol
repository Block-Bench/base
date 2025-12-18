pragma solidity ^0.4.16;

library SafeMath {
  function ae(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function ak(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;

    return c;
  }

  function ah(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function aj(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public f;
  function l(address ag) public constant returns (uint256);
  function transfer(address al, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed al, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) p;

  function transfer(address af, uint256 y) public returns (bool) {
    require(af != address(0));
    require(y > 0 && y <= p[msg.sender]);


    p[msg.sender] = p[msg.sender].ah(y);
    p[af] = p[af].aj(y);
    Transfer(msg.sender, af, y);
    return true;
  }

  function l(address v) public constant returns (uint256 balance) {
    return p[v];
  }
}

contract ERC20 is ERC20Basic {
  function i(address aa, address q) public constant returns (uint256);
  function e(address from, address al, uint256 value) public returns (bool);
  function t(address q, uint256 value) public returns (bool);
  event Approval(address indexed aa, address indexed q, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal u;

  function e(address ab, address af, uint256 y) public returns (bool) {
    require(af != address(0));
    require(y > 0 && y <= p[ab]);
    require(y <= u[ab][msg.sender]);

    p[ab] = p[ab].ah(y);
    p[af] = p[af].aj(y);
    u[ab][msg.sender] = u[ab][msg.sender].ah(y);
    Transfer(ab, af, y);
    return true;
  }

  function t(address n, uint256 y) public returns (bool) {
    u[msg.sender][n] = y;
    Approval(msg.sender, n, y);
    return true;
  }

  function i(address v, address n) public constant returns (uint256 j) {
    return u[v][n];
  }
}

contract Ownable {
  address public aa;

  event OwnershipTransferred(address indexed b, address indexed m);

  function Ownable() {
    aa = msg.sender;
  }

  modifier k() {
    require(msg.sender == aa);
    _;
  }

  function a(address m) k public {
    require(m != address(0));
    OwnershipTransferred(aa, m);
    aa = m;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public z = false;

  modifier c() {
    require(!z);
    _;
  }

  modifier h() {
    require(z);
    _;
  }

  function ac() k c public {
    z = true;
    Pause();
  }

  function r() k h public {
    z = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address af, uint256 y) public c returns (bool) {
    return super.transfer(af, y);
  }

  function e(address ab, address af, uint256 y) public c returns (bool) {
    return super.e(ab, af, y);
  }

  function t(address n, uint256 y) public c returns (bool) {
    return super.t(n, y);
  }

  function d(address[] g, uint256 y) public c returns (bool) {
    uint ai = g.length;
    uint256 w = uint256(ai) * y;
    require(ai > 0 && ai <= 20);
    require(y > 0 && p[msg.sender] >= w);

    p[msg.sender] = p[msg.sender].ah(w);
    for (uint i = 0; i < ai; i++) {
        p[g[i]] = p[g[i]].aj(y);
        Transfer(msg.sender, g[i], y);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public ad = "BeautyChain";
    string public x = "BEC";
    string public s = '1.0.0';
    uint8 public o = 18;

    function BecToken() {
      f = 7000000000 * (10**(uint256(o)));
      p[msg.sender] = f;
    }

    function () {

        revert();
    }
}