pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract AgreementTest is Test {
    supervisorGame directorGameAgreement;

    function testVisibility() public {
        directorGameAgreement = new supervisorGame();
        console.chart(
            "Before operation",
            directorGameAgreement.owner()
        );
        directorGameAgreement.changeDirector(msg.sender);
        console.chart(
            "After operation",
            directorGameAgreement.owner()
        );
        console.chart("operate completed");
    }

    receive() external payable {}
}

contract supervisorGame {
    address public owner;

    constructor() {
        owner = msg.sender;
    }


    function changeDirector(address _new) public {
        owner = _new;
    }
}