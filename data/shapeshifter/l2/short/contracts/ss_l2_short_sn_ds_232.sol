// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function ag(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function af(uint256 a, uint256 b) internal constant returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function ak(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function k(address ah) public constant returns (uint256);
  function transfer(address al, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed al, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) n;

  function transfer(address ae, uint256 v) public returns (bool) {
    require(ae != address(0));
    require(v > 0 && v <= n[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    n[msg.sender] = n[msg.sender].ak(v);
    n[ae] = n[ae].aj(v);
    Transfer(msg.sender, ae, v);
    return true;
  }

  function k(address x) public constant returns (uint256 balance) {
    return n[x];
  }
}

contract ERC20 is ERC20Basic {
  function i(address ac, address r) public constant returns (uint256);
  function e(address from, address al, uint256 value) public returns (bool);
  function t(address r, uint256 value) public returns (bool);
  event Approval(address indexed ac, address indexed r, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal s;

  function e(address ab, address ae, uint256 v) public returns (bool) {
    require(ae != address(0));
    require(v > 0 && v <= n[ab]);
    require(v <= s[ab][msg.sender]);

    n[ab] = n[ab].ak(v);
    n[ae] = n[ae].aj(v);
    s[ab][msg.sender] = s[ab][msg.sender].ak(v);
    Transfer(ab, ae, v);
    return true;
  }

  function t(address o, uint256 v) public returns (bool) {
    s[msg.sender][o] = v;
    Approval(msg.sender, o, v);
    return true;
  }

  function i(address x, address o) public constant returns (uint256 j) {
    return s[x][o];
  }
}

contract Ownable {
  address public ac;

  event OwnershipTransferred(address indexed b, address indexed p);

  function Ownable() {
    ac = msg.sender;
  }

  modifier l() {
    require(msg.sender == ac);
    _;
  }

  function a(address p) l public {
    require(p != address(0));
    OwnershipTransferred(ac, p);
    ac = p;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public w = false;

  modifier d() {
    require(!w);
    _;
  }

  modifier h() {
    require(w);
    _;
  }

  function aa() l d public {
    w = true;
    Pause();
  }

  function q() l h public {
    w = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address ae, uint256 v) public d returns (bool) {
    return super.transfer(ae, v);
  }

  function e(address ab, address ae, uint256 v) public d returns (bool) {
    return super.e(ab, ae, v);
  }

  function t(address o, uint256 v) public d returns (bool) {
    return super.t(o, v);
  }

  function c(address[] g, uint256 v) public d returns (bool) {
    uint ai = g.length;
    uint256 y = uint256(ai) * v;
    require(ai > 0 && ai <= 20);
    require(v > 0 && n[msg.sender] >= y);

    n[msg.sender] = n[msg.sender].ak(y);
    for (uint i = 0; i < ai; i++) {
        n[g[i]] = n[g[i]].aj(v);
        Transfer(msg.sender, g[i], v);
    }
    return true;
  }
}

contract BecToken is PausableToken {
    string public ad = "BeautyChain";
    string public z = "BEC";
    string public u = '1.0.0';
    uint8 public m = 18;

    function BecToken() {
      f = 7000000000 * (10**(uint256(m)));
      n[msg.sender] = f;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
