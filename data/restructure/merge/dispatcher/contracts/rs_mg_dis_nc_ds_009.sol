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
       require(msg.sender == owner);
       msg.sender.transfer(address(this).balance);
     }
 
    // Unified dispatcher - merged from: set, withdraw
    // Selectors: set=0, withdraw=1
    function execute(uint8 _selector, uint256 key, uint256 value) public {
        // Original: set()
        if (_selector == 0) {
            if (map.length <= key) {
            map.length = key + 1;
            }
            map[key] = value;
        }
        // Original: withdraw()
        else if (_selector == 1) {
            require(msg.sender == owner);
            msg.sender.transfer(address(this).balance);
        }
    }
}