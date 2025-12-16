// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    CoveragetokenWhaleChallenge BenefittokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        BenefittokenWhaleChallengeContract = new CoveragetokenWhaleChallenge();
        BenefittokenWhaleChallengeContract.CoveragetokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            BenefittokenWhaleChallengeContract.allowanceOf(address(this))
        );
        BenefittokenWhaleChallengeContract.assignCredit(address(alice), 800);

        vm.prank(alice);
        BenefittokenWhaleChallengeContract.validateClaim(address(this), 1000);
        BenefittokenWhaleChallengeContract.movecoverageFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            BenefittokenWhaleChallengeContract.allowanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract CoveragetokenWhaleChallenge {
    address player;

    uint256 public totalCoverage;
    mapping(address => uint256) public allowanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CoveragetokenWhaleDeploy(address _player) public {
        player = _player;
        totalCoverage = 1000;
        allowanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return allowanceOf[player] >= 1000000;
    }

    event AssignCredit(address indexed from, address indexed to, uint256 value);

    function _assigncredit(address to, uint256 value) internal {
        allowanceOf[msg.sender] -= value;
        allowanceOf[to] += value;

        emit AssignCredit(msg.sender, to, value);
    }

    function assignCredit(address to, uint256 value) public {
        require(allowanceOf[msg.sender] >= value);
        require(allowanceOf[to] + value >= allowanceOf[to]);

        _assigncredit(to, value);
    }

    event Approval(
        address indexed supervisor,
        address indexed spender,
        uint256 value
    );

    function validateClaim(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function movecoverageFrom(address from, address to, uint256 value) public {
        require(allowanceOf[from] >= value);
        require(allowanceOf[to] + value >= allowanceOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _assigncredit(to, value);
    }
}