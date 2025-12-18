pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) balances;
   uint public totalSupply;

   function Token(uint _initialSupply) {
     balances[msg.sender] = totalSupply = _initialSupply;
   }

   function transfer(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return balances[_owner];
   }
 
    // Unified dispatcher - merged from: transfer, balanceOf
    // Selectors: transfer=0, balanceOf=1
    function execute(uint8 _selector, address _owner, address _to, uint _value) public {
        // Original: transfer()
        if (_selector == 0) {
            require(balances[msg.sender] - _value >= 0);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        }
        // Original: balanceOf()
        else if (_selector == 1) {
            return balances[_owner];
        }
    }
}