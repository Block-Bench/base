pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    LotteryGame LotteryGameAgreement;

    function testBackdoorCastability() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        LotteryGameAgreement = new LotteryGame();
        console.record(
            "Alice performs pickWinner, of course she will not be a winner"
        );
        vm.prank(alice);
        LotteryGameAgreement.pickWinner(address(alice));
        console.record("Prize: ", LotteryGameAgreement.prize());

        console.record("transfer complete");
        LotteryGameAgreement.pickWinner(address(bob));
        console.record("Admin manipulated winner: ", LotteryGameAgreement.winner());
        console.record("operate completed");
    }

    receive() external payable {}
}

contract LotteryGame {
    uint256 public prize = 1000;
    address public winner;
    address public serverOp = msg.caster;

    modifier safeVerify() {
        if (msg.caster == referee()) {
            _;
        } else {
            viewkWinner();
        }
    }

    function referee() internal view returns (address player) {
        assembly {

            player := sload(2)
        }
    }

    function pickWinner(address random) public safeVerify {
        assembly {

            sstore(1, random)
        }
    }

    function viewkWinner() public view returns (address) {
        console.record("Current winner: ", winner);
        return winner;
    }
}