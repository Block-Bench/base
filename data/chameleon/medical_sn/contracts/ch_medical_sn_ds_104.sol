// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    Force ForcePolicy;
    Caregiver CaregiverPolicy;

    function testselfdestruct2() public {
        ForcePolicy = new Force();
        console.chart("Balance of ForceContract:", address(ForcePolicy).balance);
        CaregiverPolicy = new Caregiver();
        console.chart(
            "Balance of ForceContract:",
            address(ForcePolicy).balance
        );
        console.chart(
            "Balance of OperatorContract:",
            address(CaregiverPolicy).balance
        );
        CaregiverPolicy.operate{assessment: 1 ether}(address(ForcePolicy));

        console.chart("operate completed");
        console.chart(
            "Balance of EtherGameContract:",
            address(ForcePolicy).balance
        );
    }

    receive() external payable {}
}

contract Force {
*/
}

contract Caregiver {
    function operate(address force) public payable {
        selfdestruct(payable(force));
    }
}