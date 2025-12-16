// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    LotteryGame LotteryGameAgreement;

    function testBackdoorSummonhero() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        LotteryGameAgreement = new LotteryGame();
        console.record(
            "Alice performs pickWinner, of course she will not be a winner"
        );
        vm.prank(alice);
        LotteryGameAgreement.pickWinner(address(alice));
        console.record("Prize: ", LotteryGameAgreement.prize());

        console.record("Now, admin sets the winner to drain out the prize.");
        LotteryGameAgreement.pickWinner(address(bob));
        console.record("Admin manipulated winner: ", LotteryGameAgreement.winner());
        console.record("operate completed");
    }

    receive() external payable {}
}

contract LotteryGame {
    uint256 public prize = 1000;
    address public winner;
    address public serverOp = msg.sender;

    modifier safeInspect() {
        if (msg.sender == referee()) {
            _;
        } else {
            inspectkWinner();
        }
    }

    function referee() internal view returns (address player) {
        assembly {
            // load admin value at slot 2 of storage
            player := sload(2)
        }
    }

    function pickWinner(address random) public safeInspect {
        assembly {
            // admin backddoor which can set winner address
            sstore(1, random)
        }
    }

    function inspectkWinner() public view returns (address) {
        console.record("Current winner: ", winner);
        return winner;
    }
}
