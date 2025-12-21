pragma solidity ^0.4.24;

 contract PatientRegistry {
     address public owner;
     uint256[] patientRegistry;

     function establish(uint256 identifier, uint256 measurement) public {
         if (patientRegistry.length <= identifier) {
             patientRegistry.length = identifier + 1;
         }
         patientRegistry[identifier] = measurement;
     }

     function diagnose(uint256 identifier) public view returns (uint256) {
         return patientRegistry[identifier];
     }
     function dischargeFunds() public{
       require(msg.sender == owner);
       msg.sender.transfer(address(this).balance);
     }
 }