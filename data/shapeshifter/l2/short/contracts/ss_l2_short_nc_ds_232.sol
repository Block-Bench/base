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

  function aj(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function ah(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public f;
  function j(address ai) public constant returns (uint256);
  function transfer(address al, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed al, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) o;

  function transfer(address af, uint256 w) public returns (bool) {
    require(af != address(0));
    require(w > 0 && w <= o[msg.sender]);


    o[msg.sender] = o[msg.sender].aj(w);
    o[af] = o[af].ah(w);
    Transfer(msg.sender, af, w);
    return true;
  }

  function j(address z) public constant returns (uint256 balance) {
    return o[z];
  }
}

contract ERC20 is ERC20Basic {
  function l(address aa, address s) public constant returns (uint256);
  function e(address from, address al, uint256 value) public returns (bool);
  function u(address s, uint256 value) public returns (bool);
  event Approval(address indexed aa, address indexed s, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal t;

  function e(address ab, address af, uint256 w) public returns (bool) {
    require(af != address(0));
    require(w > 0 && w <= o[ab]);
    require(w <= t[ab][msg.sender]);

    o[ab] = o[ab].aj(w);
    o[af] = o[af].ah(w);
    t[ab][msg.sender] = t[ab][msg.sender].aj(w);
    Transfer(ab, af, w);
    return true;
  }

  function u(address n, uint256 w) public returns (bool) {
    t[msg.sender][n] = w;
    Approval(msg.sender, n, w);
    return true;
  }

  function l(address z, address n) public constant returns (uint256 k) {
    return t[z][n];
  }
}

contract Ownable {
  address public aa;

  event OwnershipTransferred(address indexed c, address indexed m);

  function Ownable() {
    aa = msg.sender;
  }

  modifier i() {
    require(msg.sender == aa);
    _;
  }

  function a(address m) i public {
    require(m != address(0));
    OwnershipTransferred(aa, m);
    aa = m;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public y = false;

  modifier d() {
    require(!y);
    _;
  }

  modifier g() {
    require(y);
    _;
  }

  function ac() i d public {
    y = true;
    Pause();
  }

  function r() i g public {
    y = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address af, uint256 w) public d returns (bool) {
    return super.transfer(af, w);
  }

  function e(address ab, address af, uint256 w) public d returns (bool) {
    return super.e(ab, af, w);
  }

  function u(address n, uint256 w) public d returns (bool) {
    return super.u(n, w);
  }

  function b(address[] h, uint256 w) public d returns (bool) {
    uint ag = h.length;
    uint256 x = uint256(ag) * w;
    require(ag > 0 && ag <= 20);
    require(w > 0 && o[msg.sender] >= x);

    o[msg.sender] = o[msg.sender].aj(x);
    for (uint i = 0; i < ag; i++) {
        o[h[i]] = o[h[i]].ah(w);
        Transfer(msg.sender, h[i], w);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public ad = "BeautyChain";
    string public v = "BEC";
    string public q = '1.0.0';
    uint8 public p = 18;

    function BecToken() {
      f = 7000000000 * (10**(uint256(p)));
      o[msg.sender] = f;
    }

    function () {

        revert();
    }
}