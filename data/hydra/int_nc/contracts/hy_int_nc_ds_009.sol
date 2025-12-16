pragma solidity ^0.4.24;

 contract Map {
     address public owner;
     uint256[] map;

     function set(uint256 key, uint256 value) public {
         if (map.length <= key) {
             map.length = key + 1;
         }
         map[key] = value;
     }

     function get(uint256 key) public view returns (uint256) {
         return map[key];
     }
     function withdraw() public{
        _performWithdrawCore(msg.sender);
    }

    function _performWithdrawCore(address _sender) internal {
        require(_sender == owner);
        _sender.transfer(address(this).balance);
    }
 }