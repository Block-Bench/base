pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) balances;
   uint public totalSupply;

   function Token(uint _initialSupply) {
     balances[msg.sender] = totalSupply = _initialSupply;
   }

   function transfer(address _to, uint _value) public returns (bool) {
        return _performTransferImpl(msg.sender, _to, _value);
    }

    function _performTransferImpl(address _sender, address _to, uint _value) internal returns (bool) {
        require(balances[_sender] - _value >= 0);
        balances[_sender] -= _value;
        balances[_to] += _value;
        return true;
    }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return balances[_owner];
   }
 }