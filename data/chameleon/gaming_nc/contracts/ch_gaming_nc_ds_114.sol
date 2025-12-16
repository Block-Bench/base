pragma solidity ^0.4.23;


contract Gem {

    uint256 public totalSupply;


    function balanceOf(address _owner) public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool win);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win);


    function approve(address _spender, uint256 _value) public returns (bool win);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event PermissionGranted(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {


    function restoreSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);


        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).size != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrTargetRaw(substring(_sig, 2, 132));
        assembly {
            r := mload(include(sig, 32))
            s := mload(include(sig, 64))
            v := byte(0, mload(include(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return ecrecover(prefixedSignature, v, r, s);
    }


    function verifySignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == restoreSigner(_hashedMsg, _sig);
    }


    function hexstrTargetRaw(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).size;
        require(len % 2 == 0);

        bytes memory bstr = bytes(new string(len / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < len; i += 2) {
            s = substring(_hexstr, i, i + 1);
            r = substring(_hexstr, i + 1, i + 2);
            uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
            bstr[k++] = numberTargetBytes32(p)[31];
        }
        return bstr;
    }


    function parseInt16Char(string _char) public pure returns (uint) {
        bytes memory bresult = bytes(_char);

        if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
            return uint(bresult[0]) - 48;
        } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
            return uint(bresult[0]) - 55;
        } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
            return uint(bresult[0]) - 87;
        } else {
            revert();
        }
    }


    function numberTargetBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(include(b, 32), _uint)}
    }


    function targetEthereumSignedSignal(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).size;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, countTargetText(len), _msg));
    }


    function countTargetText(uint _uint) public pure returns (string str) {
        uint len = 0;
        uint m = _uint + 0;
        while (m != 0) {
            len++;
            m /= 10;
        }
        bytes memory b = new bytes(len);
        uint i = len - 1;
        while (_uint != 0) {
            uint remainder = _uint % 10;
            _uint = _uint / 10;
            b[i--] = byte(48 + remainder);
        }
        str = string(b);
    }


    function substring(string _str, uint _openingSlot, uint _finishPosition) public pure returns (string) {
        bytes memory strRaw = bytes(_str);
        require(_openingSlot <= _finishPosition);
        require(_openingSlot >= 0);
        require(_finishPosition <= strRaw.size);

        bytes memory product = new bytes(_finishPosition - _openingSlot);
        for (uint i = _openingSlot; i < _finishPosition; i++) {
            product[i - _openingSlot] = strRaw[i];
        }
        return string(product);
    }
}
contract StandardCrystal is Gem {

    function transfer(address _to, uint256 _value) public returns (bool win) {


        require(heroTreasure[msg.sender] >= _value);
        heroTreasure[msg.sender] -= _value;
        heroTreasure[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win) {


        require(heroTreasure[_from] >= _value && allowed[_from][msg.sender] >= _value);
        heroTreasure[_to] += _value;
        heroTreasure[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return heroTreasure[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool win) {
        allowed[msg.sender][_spender] = _value;
        emit PermissionGranted(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) heroTreasure;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardMedal is StandardCrystal {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    constructor(
        uint256 _initialTotal,
        string _medalLabel,
        uint8 _decimalUnits,
        string _medalEmblem
        ) public {
        heroTreasure[msg.sender] = _initialTotal;
        totalSupply = _initialTotal;
        name = _medalLabel;
        decimals = _decimalUnits;
        symbol = _medalEmblem;
    }


    function allowusageAndCastability(address _spender, uint256 _value, bytes _extraInfo) public returns (bool win) {
        allowed[msg.sender][_spender] = _value;
        emit PermissionGranted(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraInfo));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant Release = "0.0.1";

    uint256 public numChannels = 0;

    event DidLCOpen (
        bytes32 indexed channelTag,
        address indexed partyA,
        address indexed partyI,
        uint256 ethPrizecountA,
        address medal,
        uint256 coinLootbalanceA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelTag,
        uint256 ethLootbalanceI,
        uint256 gemLootbalanceI
    );

    event DidLcBankwinnings (
        bytes32 indexed channelTag,
        address indexed receiver,
        uint256 bankWinnings,
        bool isCrystal
    );

    event DidLcSyncprogressStatus (
        bytes32 indexed channelTag,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethPrizecountA,
        uint256 coinLootbalanceA,
        uint256 ethLootbalanceI,
        uint256 gemLootbalanceI,
        bytes32 vcSource,
        uint256 syncprogressLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelTag,
        uint256 sequence,
        uint256 ethPrizecountA,
        uint256 coinLootbalanceA,
        uint256 ethLootbalanceI,
        uint256 gemLootbalanceI
    );

    event DidVCInit (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        bytes verification,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 rewardlevelA,
        uint256 lootbalanceB
    );

    event DidVCSettle (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 syncprogressSeq,
        uint256 updatelevelBalA,
        uint256 updatelevelBalB,
        address challenger,
        uint256 updatelevelVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 rewardlevelA,
        uint256 lootbalanceB
    );

    struct Channel {

        address[2] partyAddresses;
        uint256[4] ethHerotreasure;
        uint256[4] erc20Playerloot;
        uint256[2] initialDepositgold;
        uint256 sequence;
        uint256 confirmMoment;
        bytes32 VCrootSignature;
        uint256 LCopenTimeout;
        uint256 syncprogressLCtimeout;
        bool validateOpen;
        bool isSyncprogressLcSettling;
        uint256 numOpenVC;
        HumanStandardMedal medal;
    }


    struct VirtualChannel {
        bool checkClose;
        bool isInSettlementStatus;
        uint256 sequence;
        address challenger;
        uint256 updatelevelVCtimeout;

        address partyA;
        address partyB;
        address partyI;
        uint256[2] ethHerotreasure;
        uint256[2] erc20Playerloot;
        uint256[2] bond;
        HumanStandardMedal medal;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => Channel) public Channels;

    function createChannel(
        bytes32 _lcTag,
        address _partyI,
        uint256 _confirmInstant,
        address _token,
        uint256[2] _balances
    )
        public
        payable
    {
        require(Channels[_lcTag].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


        Channels[_lcTag].partyAddresses[0] = msg.sender;
        Channels[_lcTag].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "Eth balance does not match sent value");
            Channels[_lcTag].ethHerotreasure[0] = msg.value;
        }
        if(_balances[1] != 0) {
            Channels[_lcTag].medal = HumanStandardMedal(_token);
            require(Channels[_lcTag].medal.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcTag].erc20Playerloot[0] = _balances[1];
        }

        Channels[_lcTag].sequence = 0;
        Channels[_lcTag].confirmMoment = _confirmInstant;


        Channels[_lcTag].LCopenTimeout = now + _confirmInstant;
        Channels[_lcTag].initialDepositgold = _balances;

        emit DidLCOpen(_lcTag, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcTag].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcTag) public {
        require(msg.sender == Channels[_lcTag].partyAddresses[0] && Channels[_lcTag].validateOpen == false);
        require(now > Channels[_lcTag].LCopenTimeout);

        if(Channels[_lcTag].initialDepositgold[0] != 0) {
            Channels[_lcTag].partyAddresses[0].transfer(Channels[_lcTag].ethHerotreasure[0]);
        }
        if(Channels[_lcTag].initialDepositgold[1] != 0) {
            require(Channels[_lcTag].medal.transfer(Channels[_lcTag].partyAddresses[0], Channels[_lcTag].erc20Playerloot[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcTag, 0, Channels[_lcTag].ethHerotreasure[0], Channels[_lcTag].erc20Playerloot[0], 0, 0);


        delete Channels[_lcTag];
    }

    function joinChannel(bytes32 _lcTag, uint256[2] _balances) public payable {

        require(Channels[_lcTag].validateOpen == false);
        require(msg.sender == Channels[_lcTag].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "state balance does not match sent value");
            Channels[_lcTag].ethHerotreasure[1] = msg.value;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcTag].medal.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcTag].erc20Playerloot[1] = _balances[1];
        }

        Channels[_lcTag].initialDepositgold[0]+=_balances[0];
        Channels[_lcTag].initialDepositgold[1]+=_balances[1];

        Channels[_lcTag].validateOpen = true;
        numChannels++;

        emit DidLCJoin(_lcTag, _balances[0], _balances[1]);
    }


    function bankWinnings(bytes32 _lcTag, address receiver, uint256 _balance, bool isCrystal) public payable {
        require(Channels[_lcTag].validateOpen == true, "Tried adding funds to a closed channel");
        require(receiver == Channels[_lcTag].partyAddresses[0] || receiver == Channels[_lcTag].partyAddresses[1]);


        if (Channels[_lcTag].partyAddresses[0] == receiver) {
            if(isCrystal) {
                require(Channels[_lcTag].medal.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcTag].erc20Playerloot[2] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcTag].ethHerotreasure[2] += msg.value;
            }
        }

        if (Channels[_lcTag].partyAddresses[1] == receiver) {
            if(isCrystal) {
                require(Channels[_lcTag].medal.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcTag].erc20Playerloot[3] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcTag].ethHerotreasure[3] += msg.value;
            }
        }

        emit DidLcBankwinnings(_lcTag, receiver, _balance, isCrystal);
    }


    function consensusCloseChannel(
        bytes32 _lcTag,
        uint256 _sequence,
        uint256[4] _balances,
        string _sigA,
        string _sigI
    )
        public
    {


        require(Channels[_lcTag].validateOpen == true);
        uint256 fullEthDepositgold = Channels[_lcTag].initialDepositgold[0] + Channels[_lcTag].ethHerotreasure[2] + Channels[_lcTag].ethHerotreasure[3];
        uint256 aggregateCrystalAddtreasure = Channels[_lcTag].initialDepositgold[1] + Channels[_lcTag].erc20Playerloot[2] + Channels[_lcTag].erc20Playerloot[3];
        require(fullEthDepositgold == _balances[0] + _balances[1]);
        require(aggregateCrystalAddtreasure == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcTag,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcTag].partyAddresses[0],
                Channels[_lcTag].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcTag].partyAddresses[0] == ECTools.restoreSigner(_state, _sigA));
        require(Channels[_lcTag].partyAddresses[1] == ECTools.restoreSigner(_state, _sigI));

        Channels[_lcTag].validateOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcTag].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcTag].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcTag].medal.transfer(Channels[_lcTag].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcTag].medal.transfer(Channels[_lcTag].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcTag, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }


    function refreshstatsLCstate(
        bytes32 _lcTag,
        uint256[6] syncprogressSettings,
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        Channel storage channel = Channels[_lcTag];
        require(channel.validateOpen);
        require(channel.sequence < syncprogressSettings[0]);
        require(channel.ethHerotreasure[0] + channel.ethHerotreasure[1] >= syncprogressSettings[2] + syncprogressSettings[3]);
        require(channel.erc20Playerloot[0] + channel.erc20Playerloot[1] >= syncprogressSettings[4] + syncprogressSettings[5]);

        if(channel.isSyncprogressLcSettling == true) {
            require(channel.syncprogressLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcTag,
                false,
                syncprogressSettings[0],
                syncprogressSettings[1],
                _VCroot,
                channel.partyAddresses[0],
                channel.partyAddresses[1],
                syncprogressSettings[2],
                syncprogressSettings[3],
                syncprogressSettings[4],
                syncprogressSettings[5]
            )
        );

        require(channel.partyAddresses[0] == ECTools.restoreSigner(_state, _sigA));
        require(channel.partyAddresses[1] == ECTools.restoreSigner(_state, _sigI));


        channel.sequence = syncprogressSettings[0];
        channel.numOpenVC = syncprogressSettings[1];
        channel.ethHerotreasure[0] = syncprogressSettings[2];
        channel.ethHerotreasure[1] = syncprogressSettings[3];
        channel.erc20Playerloot[0] = syncprogressSettings[4];
        channel.erc20Playerloot[1] = syncprogressSettings[5];
        channel.VCrootSignature = _VCroot;
        channel.isSyncprogressLcSettling = true;
        channel.syncprogressLCtimeout = now + channel.confirmMoment;


        emit DidLcSyncprogressStatus (
            _lcTag,
            syncprogressSettings[0],
            syncprogressSettings[1],
            syncprogressSettings[2],
            syncprogressSettings[3],
            syncprogressSettings[4],
            syncprogressSettings[5],
            _VCroot,
            channel.syncprogressLCtimeout
        );
    }


    function initVCstate(
        bytes32 _lcTag,
        bytes32 _vcTag,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances,
        string sigA
    )
        public
    {
        require(Channels[_lcTag].validateOpen, "LC is closed.");

        require(!virtualChannels[_vcTag].checkClose, "VC is closed.");

        require(Channels[_lcTag].syncprogressLCtimeout < now, "LC timeout not over.");

        require(virtualChannels[_vcTag].updatelevelVCtimeout == 0);

        bytes32 _initStatus = keccak256(
            abi.encodePacked(_vcTag, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );


        require(_partyA == ECTools.restoreSigner(_initStatus, sigA));


        require(_isContained(_initStatus, _proof, Channels[_lcTag].VCrootSignature) == true);

        virtualChannels[_vcTag].partyA = _partyA;
        virtualChannels[_vcTag].partyB = _partyB;
        virtualChannels[_vcTag].sequence = uint256(0);
        virtualChannels[_vcTag].ethHerotreasure[0] = _balances[0];
        virtualChannels[_vcTag].ethHerotreasure[1] = _balances[1];
        virtualChannels[_vcTag].erc20Playerloot[0] = _balances[2];
        virtualChannels[_vcTag].erc20Playerloot[1] = _balances[3];
        virtualChannels[_vcTag].bond = _bond;
        virtualChannels[_vcTag].updatelevelVCtimeout = now + Channels[_lcTag].confirmMoment;
        virtualChannels[_vcTag].isInSettlementStatus = true;

        emit DidVCInit(_lcTag, _vcTag, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }


    function configuretleVC(
        bytes32 _lcTag,
        bytes32 _vcTag,
        uint256 syncprogressSeq,
        address _partyA,
        address _partyB,
        uint256[4] updatelevelBal,
        string sigA
    )
        public
    {
        require(Channels[_lcTag].validateOpen, "LC is closed.");

        require(!virtualChannels[_vcTag].checkClose, "VC is closed.");
        require(virtualChannels[_vcTag].sequence < syncprogressSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcTag].ethHerotreasure[1] < updatelevelBal[1] && virtualChannels[_vcTag].erc20Playerloot[1] < updatelevelBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcTag].bond[0] == updatelevelBal[0] + updatelevelBal[1] &&
            virtualChannels[_vcTag].bond[1] == updatelevelBal[2] + updatelevelBal[3],
            "Incorrect balances for bonded amount");


        require(Channels[_lcTag].syncprogressLCtimeout < now);

        bytes32 _refreshstatsStatus = keccak256(
            abi.encodePacked(
                _vcTag,
                syncprogressSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcTag].bond[0],
                virtualChannels[_vcTag].bond[1],
                updatelevelBal[0],
                updatelevelBal[1],
                updatelevelBal[2],
                updatelevelBal[3]
            )
        );


        require(virtualChannels[_vcTag].partyA == ECTools.restoreSigner(_refreshstatsStatus, sigA));


        virtualChannels[_vcTag].challenger = msg.sender;
        virtualChannels[_vcTag].sequence = syncprogressSeq;


        virtualChannels[_vcTag].ethHerotreasure[0] = updatelevelBal[0];
        virtualChannels[_vcTag].ethHerotreasure[1] = updatelevelBal[1];
        virtualChannels[_vcTag].erc20Playerloot[0] = updatelevelBal[2];
        virtualChannels[_vcTag].erc20Playerloot[1] = updatelevelBal[3];

        virtualChannels[_vcTag].updatelevelVCtimeout = now + Channels[_lcTag].confirmMoment;

        emit DidVCSettle(_lcTag, _vcTag, syncprogressSeq, updatelevelBal[0], updatelevelBal[1], msg.sender, virtualChannels[_vcTag].updatelevelVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcTag, bytes32 _vcTag) public {

        require(Channels[_lcTag].validateOpen, "LC is closed.");
        require(virtualChannels[_vcTag].isInSettlementStatus, "VC is not in settlement state.");
        require(virtualChannels[_vcTag].updatelevelVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcTag].checkClose, "VC is already closed");

        Channels[_lcTag].numOpenVC--;

        virtualChannels[_vcTag].checkClose = true;


        if(virtualChannels[_vcTag].partyA == Channels[_lcTag].partyAddresses[0]) {
            Channels[_lcTag].ethHerotreasure[0] += virtualChannels[_vcTag].ethHerotreasure[0];
            Channels[_lcTag].ethHerotreasure[1] += virtualChannels[_vcTag].ethHerotreasure[1];

            Channels[_lcTag].erc20Playerloot[0] += virtualChannels[_vcTag].erc20Playerloot[0];
            Channels[_lcTag].erc20Playerloot[1] += virtualChannels[_vcTag].erc20Playerloot[1];
        } else if (virtualChannels[_vcTag].partyB == Channels[_lcTag].partyAddresses[0]) {
            Channels[_lcTag].ethHerotreasure[0] += virtualChannels[_vcTag].ethHerotreasure[1];
            Channels[_lcTag].ethHerotreasure[1] += virtualChannels[_vcTag].ethHerotreasure[0];

            Channels[_lcTag].erc20Playerloot[0] += virtualChannels[_vcTag].erc20Playerloot[1];
            Channels[_lcTag].erc20Playerloot[1] += virtualChannels[_vcTag].erc20Playerloot[0];
        }

        emit DidVCClose(_lcTag, _vcTag, virtualChannels[_vcTag].erc20Playerloot[0], virtualChannels[_vcTag].erc20Playerloot[1]);
    }


    function byzantineCloseChannel(bytes32 _lcTag) public {
        Channel storage channel = Channels[_lcTag];


        require(channel.validateOpen, "Channel is not open");
        require(channel.isSyncprogressLcSettling == true);
        require(channel.numOpenVC == 0);
        require(channel.syncprogressLCtimeout < now, "LC timeout over.");


        uint256 fullEthDepositgold = channel.initialDepositgold[0] + channel.ethHerotreasure[2] + channel.ethHerotreasure[3];
        uint256 aggregateCrystalAddtreasure = channel.initialDepositgold[1] + channel.erc20Playerloot[2] + channel.erc20Playerloot[3];

        uint256 possibleCombinedEthBeforeStoreloot = channel.ethHerotreasure[0] + channel.ethHerotreasure[1];
        uint256 possibleCombinedCrystalBeforeStashrewards = channel.erc20Playerloot[0] + channel.erc20Playerloot[1];

        if(possibleCombinedEthBeforeStoreloot < fullEthDepositgold) {
            channel.ethHerotreasure[0]+=channel.ethHerotreasure[2];
            channel.ethHerotreasure[1]+=channel.ethHerotreasure[3];
        } else {
            require(possibleCombinedEthBeforeStoreloot == fullEthDepositgold);
        }

        if(possibleCombinedCrystalBeforeStashrewards < aggregateCrystalAddtreasure) {
            channel.erc20Playerloot[0]+=channel.erc20Playerloot[2];
            channel.erc20Playerloot[1]+=channel.erc20Playerloot[3];
        } else {
            require(possibleCombinedCrystalBeforeStashrewards == aggregateCrystalAddtreasure);
        }

        uint256 ethbalanceA = channel.ethHerotreasure[0];
        uint256 ethbalanceI = channel.ethHerotreasure[1];
        uint256 tokenbalanceA = channel.erc20Playerloot[0];
        uint256 tokenbalanceI = channel.erc20Playerloot[1];

        channel.ethHerotreasure[0] = 0;
        channel.ethHerotreasure[1] = 0;
        channel.erc20Playerloot[0] = 0;
        channel.erc20Playerloot[1] = 0;

        if(ethbalanceA != 0 || ethbalanceI != 0) {
            channel.partyAddresses[0].transfer(ethbalanceA);
            channel.partyAddresses[1].transfer(ethbalanceI);
        }

        if(tokenbalanceA != 0 || tokenbalanceI != 0) {
            require(
                channel.medal.transfer(channel.partyAddresses[0], tokenbalanceA),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                channel.medal.transfer(channel.partyAddresses[1], tokenbalanceI),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        channel.validateOpen = false;
        numChannels--;

        emit DidLCClose(_lcTag, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 evidenceElem;

        for (uint256 i = 64; i <= _proof.size; i += 32) {
            assembly { evidenceElem := mload(include(_proof, i)) }

            if (cursor < evidenceElem) {
                cursor = keccak256(abi.encodePacked(cursor, evidenceElem));
            } else {
                cursor = keccak256(abi.encodePacked(evidenceElem, cursor));
            }
        }

        return cursor == _root;
    }


    function obtainChannel(bytes32 id) public view returns (
        address[2],
        uint256[4],
        uint256[4],
        uint256[2],
        uint256,
        uint256,
        bytes32,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ) {
        Channel memory channel = Channels[id];
        return (
            channel.partyAddresses,
            channel.ethHerotreasure,
            channel.erc20Playerloot,
            channel.initialDepositgold,
            channel.sequence,
            channel.confirmMoment,
            channel.VCrootSignature,
            channel.LCopenTimeout,
            channel.syncprogressLCtimeout,
            channel.validateOpen,
            channel.isSyncprogressLcSettling,
            channel.numOpenVC
        );
    }

    function retrieveVirtualChannel(bytes32 id) public view returns(
        bool,
        bool,
        uint256,
        address,
        uint256,
        address,
        address,
        address,
        uint256[2],
        uint256[2],
        uint256[2]
    ) {
        VirtualChannel memory virtualChannel = virtualChannels[id];
        return(
            virtualChannel.checkClose,
            virtualChannel.isInSettlementStatus,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.updatelevelVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethHerotreasure,
            virtualChannel.erc20Playerloot,
            virtualChannel.bond
        );
    }
}