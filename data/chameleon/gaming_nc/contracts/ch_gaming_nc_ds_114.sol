pragma solidity ^0.4.23;


contract Crystal {
    */

    uint256 public totalSupply;


    function balanceOf(address _owner) public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool victory);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory);


    function approve(address _spender, uint256 _value) public returns (bool victory);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {


    function retrieveSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);


        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).extent != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrDestinationRaw(substring(_sig, 2, 132));
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

        return _addr == retrieveSigner(_hashedMsg, _sig);
    }


    function hexstrDestinationRaw(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).extent;
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


    function destinationEthereumSignedCommunication(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).extent;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, countDestinationText(len), _msg));
    }


    function countDestinationText(uint _uint) public pure returns (string str) {
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


    function substring(string _str, uint _beginSlot, uint _finishPosition) public pure returns (string) {
        bytes memory strRaw = bytes(_str);
        require(_beginSlot <= _finishPosition);
        require(_beginSlot >= 0);
        require(_finishPosition <= strRaw.extent);

        bytes memory outcome = new bytes(_finishPosition - _beginSlot);
        for (uint i = _beginSlot; i < _finishPosition; i++) {
            outcome[i - _beginSlot] = strRaw[i];
        }
        return string(outcome);
    }
}
contract StandardCrystal is Crystal {

    function transfer(address _to, uint256 _value) public returns (bool victory) {


        require(heroTreasure[msg.initiator] >= _value);
        heroTreasure[msg.initiator] -= _value;
        heroTreasure[_to] += _value;
        emit Transfer(msg.initiator, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory) {


        require(heroTreasure[_from] >= _value && allowed[_from][msg.initiator] >= _value);
        heroTreasure[_to] += _value;
        heroTreasure[_from] -= _value;
        allowed[_from][msg.initiator] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return heroTreasure[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool victory) {
        allowed[msg.initiator][_spender] = _value;
        emit AccessAuthorized(msg.initiator, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) heroTreasure;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardGem is StandardCrystal {


    */
    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    constructor(
        uint256 _initialQuantity,
        string _coinTitle,
        uint8 _decimalUnits,
        string _medalEmblem
        ) public {
        heroTreasure[msg.initiator] = _initialQuantity;
        totalSupply = _initialQuantity;
        name = _coinTitle;
        decimals = _decimalUnits;
        symbol = _medalEmblem;
    }


    function permitaccessAndSummonhero(address _spender, uint256 _value, bytes _extraDetails) public returns (bool victory) {
        allowed[msg.initiator][_spender] = _value;
        emit AccessAuthorized(msg.initiator, _spender, _value);


        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.initiator, _value, this, _extraDetails));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant Release = "0.0.1";

    uint256 public numChannels = 0;

    event DidLCOpen (
        bytes32 indexed channelCode,
        address indexed partyA,
        address indexed partyI,
        uint256 ethTreasureamountA,
        address crystal,
        uint256 gemGoldholdingA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelCode,
        uint256 ethGoldholdingI,
        uint256 crystalPrizecountI
    );

    event DidLcStoreloot (
        bytes32 indexed channelCode,
        address indexed target,
        uint256 stashRewards,
        bool isMedal
    );

    event DidLcSyncprogressStatus (
        bytes32 indexed channelCode,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethTreasureamountA,
        uint256 gemGoldholdingA,
        uint256 ethGoldholdingI,
        uint256 crystalPrizecountI,
        bytes32 vcSource,
        uint256 syncprogressLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelCode,
        uint256 sequence,
        uint256 ethTreasureamountA,
        uint256 gemGoldholdingA,
        uint256 ethGoldholdingI,
        uint256 crystalPrizecountI
    );

    event DidVCInit (
        bytes32 indexed lcTag,
        bytes32 indexed vcCode,
        bytes evidence,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 goldholdingA,
        uint256 goldholdingB
    );

    event DidVCSettle (
        bytes32 indexed lcTag,
        bytes32 indexed vcCode,
        uint256 syncprogressSeq,
        uint256 refreshstatsBalA,
        uint256 syncprogressBalB,
        address challenger,
        uint256 syncprogressVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcTag,
        bytes32 indexed vcCode,
        uint256 goldholdingA,
        uint256 goldholdingB
    );

    struct Channel {

        address[2] partyAddresses;
        uint256[4] ethCharactergold;
        uint256[4] erc20Userrewards;
        uint256[2] initialCacheprize;
        uint256 sequence;
        uint256 confirmMoment;
        bytes32 VCrootSignature;
        uint256 LCopenTimeout;
        uint256 syncprogressLCtimeout;
        bool verifyOpen;
        bool isSyncprogressLcSettling;
        uint256 numOpenVC;
        HumanStandardGem crystal;
    }


    struct VirtualChannel {
        bool testClose;
        bool isInSettlementStatus;
        uint256 sequence;
        address challenger;
        uint256 syncprogressVCtimeout;

        address partyA;
        address partyB;
        address partyI;
        uint256[2] ethCharactergold;
        uint256[2] erc20Userrewards;
        uint256[2] bond;
        HumanStandardGem crystal;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => Channel) public Channels;

    function createChannel(
        bytes32 _lcCode,
        address _partyI,
        uint256 _confirmInstant,
        address _token,
        uint256[2] _balances
    )
        public
        payable
    {
        require(Channels[_lcCode].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


        Channels[_lcCode].partyAddresses[0] = msg.initiator;
        Channels[_lcCode].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.magnitude == _balances[0], "Eth balance does not match sent value");
            Channels[_lcCode].ethCharactergold[0] = msg.magnitude;
        }
        if(_balances[1] != 0) {
            Channels[_lcCode].crystal = HumanStandardGem(_token);
            require(Channels[_lcCode].crystal.transferFrom(msg.initiator, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcCode].erc20Userrewards[0] = _balances[1];
        }

        Channels[_lcCode].sequence = 0;
        Channels[_lcCode].confirmMoment = _confirmInstant;


        Channels[_lcCode].LCopenTimeout = now + _confirmInstant;
        Channels[_lcCode].initialCacheprize = _balances;

        emit DidLCOpen(_lcCode, msg.initiator, _partyI, _balances[0], _token, _balances[1], Channels[_lcCode].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcCode) public {
        require(msg.initiator == Channels[_lcCode].partyAddresses[0] && Channels[_lcCode].verifyOpen == false);
        require(now > Channels[_lcCode].LCopenTimeout);

        if(Channels[_lcCode].initialCacheprize[0] != 0) {
            Channels[_lcCode].partyAddresses[0].transfer(Channels[_lcCode].ethCharactergold[0]);
        }
        if(Channels[_lcCode].initialCacheprize[1] != 0) {
            require(Channels[_lcCode].crystal.transfer(Channels[_lcCode].partyAddresses[0], Channels[_lcCode].erc20Userrewards[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcCode, 0, Channels[_lcCode].ethCharactergold[0], Channels[_lcCode].erc20Userrewards[0], 0, 0);


        delete Channels[_lcCode];
    }

    function joinChannel(bytes32 _lcCode, uint256[2] _balances) public payable {

        require(Channels[_lcCode].verifyOpen == false);
        require(msg.initiator == Channels[_lcCode].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.magnitude == _balances[0], "state balance does not match sent value");
            Channels[_lcCode].ethCharactergold[1] = msg.magnitude;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcCode].crystal.transferFrom(msg.initiator, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcCode].erc20Userrewards[1] = _balances[1];
        }

        Channels[_lcCode].initialCacheprize[0]+=_balances[0];
        Channels[_lcCode].initialCacheprize[1]+=_balances[1];

        Channels[_lcCode].verifyOpen = true;
        numChannels++;

        emit DidLCJoin(_lcCode, _balances[0], _balances[1]);
    }


    function stashRewards(bytes32 _lcCode, address target, uint256 _balance, bool isMedal) public payable {
        require(Channels[_lcCode].verifyOpen == true, "Tried adding funds to a closed channel");
        require(target == Channels[_lcCode].partyAddresses[0] || target == Channels[_lcCode].partyAddresses[1]);


        if (Channels[_lcCode].partyAddresses[0] == target) {
            if(isMedal) {
                require(Channels[_lcCode].crystal.transferFrom(msg.initiator, this, _balance),"deposit: token transfer failure");
                Channels[_lcCode].erc20Userrewards[2] += _balance;
            } else {
                require(msg.magnitude == _balance, "state balance does not match sent value");
                Channels[_lcCode].ethCharactergold[2] += msg.magnitude;
            }
        }

        if (Channels[_lcCode].partyAddresses[1] == target) {
            if(isMedal) {
                require(Channels[_lcCode].crystal.transferFrom(msg.initiator, this, _balance),"deposit: token transfer failure");
                Channels[_lcCode].erc20Userrewards[3] += _balance;
            } else {
                require(msg.magnitude == _balance, "state balance does not match sent value");
                Channels[_lcCode].ethCharactergold[3] += msg.magnitude;
            }
        }

        emit DidLcStoreloot(_lcCode, target, _balance, isMedal);
    }


    function consensusCloseChannel(
        bytes32 _lcCode,
        uint256 _sequence,
        uint256[4] _balances,
        string _sigA,
        string _sigI
    )
        public
    {


        require(Channels[_lcCode].verifyOpen == true);
        uint256 aggregateEthStoreloot = Channels[_lcCode].initialCacheprize[0] + Channels[_lcCode].ethCharactergold[2] + Channels[_lcCode].ethCharactergold[3];
        uint256 completeGemCacheprize = Channels[_lcCode].initialCacheprize[1] + Channels[_lcCode].erc20Userrewards[2] + Channels[_lcCode].erc20Userrewards[3];
        require(aggregateEthStoreloot == _balances[0] + _balances[1]);
        require(completeGemCacheprize == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcCode,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcCode].partyAddresses[0],
                Channels[_lcCode].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcCode].partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
        require(Channels[_lcCode].partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));

        Channels[_lcCode].verifyOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcCode].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcCode].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcCode].crystal.transfer(Channels[_lcCode].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcCode].crystal.transfer(Channels[_lcCode].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcCode, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }


    function updatelevelLCstate(
        bytes32 _lcCode,
        uint256[6] updatelevelSettings,
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        Channel storage channel = Channels[_lcCode];
        require(channel.verifyOpen);
        require(channel.sequence < updatelevelSettings[0]);
        require(channel.ethCharactergold[0] + channel.ethCharactergold[1] >= updatelevelSettings[2] + updatelevelSettings[3]);
        require(channel.erc20Userrewards[0] + channel.erc20Userrewards[1] >= updatelevelSettings[4] + updatelevelSettings[5]);

        if(channel.isSyncprogressLcSettling == true) {
            require(channel.syncprogressLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcCode,
                false,
                updatelevelSettings[0],
                updatelevelSettings[1],
                _VCroot,
                channel.partyAddresses[0],
                channel.partyAddresses[1],
                updatelevelSettings[2],
                updatelevelSettings[3],
                updatelevelSettings[4],
                updatelevelSettings[5]
            )
        );

        require(channel.partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
        require(channel.partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));


        channel.sequence = updatelevelSettings[0];
        channel.numOpenVC = updatelevelSettings[1];
        channel.ethCharactergold[0] = updatelevelSettings[2];
        channel.ethCharactergold[1] = updatelevelSettings[3];
        channel.erc20Userrewards[0] = updatelevelSettings[4];
        channel.erc20Userrewards[1] = updatelevelSettings[5];
        channel.VCrootSignature = _VCroot;
        channel.isSyncprogressLcSettling = true;
        channel.syncprogressLCtimeout = now + channel.confirmMoment;


        emit DidLcSyncprogressStatus (
            _lcCode,
            updatelevelSettings[0],
            updatelevelSettings[1],
            updatelevelSettings[2],
            updatelevelSettings[3],
            updatelevelSettings[4],
            updatelevelSettings[5],
            _VCroot,
            channel.syncprogressLCtimeout
        );
    }


    function initVCstate(
        bytes32 _lcCode,
        bytes32 _vcCode,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances,
        string sigA
    )
        public
    {
        require(Channels[_lcCode].verifyOpen, "LC is closed.");

        require(!virtualChannels[_vcCode].testClose, "VC is closed.");

        require(Channels[_lcCode].syncprogressLCtimeout < now, "LC timeout not over.");

        require(virtualChannels[_vcCode].syncprogressVCtimeout == 0);

        bytes32 _initStatus = keccak256(
            abi.encodePacked(_vcCode, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );


        require(_partyA == ECTools.retrieveSigner(_initStatus, sigA));


        require(_isContained(_initStatus, _proof, Channels[_lcCode].VCrootSignature) == true);

        virtualChannels[_vcCode].partyA = _partyA;
        virtualChannels[_vcCode].partyB = _partyB;
        virtualChannels[_vcCode].sequence = uint256(0);
        virtualChannels[_vcCode].ethCharactergold[0] = _balances[0];
        virtualChannels[_vcCode].ethCharactergold[1] = _balances[1];
        virtualChannels[_vcCode].erc20Userrewards[0] = _balances[2];
        virtualChannels[_vcCode].erc20Userrewards[1] = _balances[3];
        virtualChannels[_vcCode].bond = _bond;
        virtualChannels[_vcCode].syncprogressVCtimeout = now + Channels[_lcCode].confirmMoment;
        virtualChannels[_vcCode].isInSettlementStatus = true;

        emit DidVCInit(_lcCode, _vcCode, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }


    function modifytleVC(
        bytes32 _lcCode,
        bytes32 _vcCode,
        uint256 syncprogressSeq,
        address _partyA,
        address _partyB,
        uint256[4] syncprogressBal,
        string sigA
    )
        public
    {
        require(Channels[_lcCode].verifyOpen, "LC is closed.");

        require(!virtualChannels[_vcCode].testClose, "VC is closed.");
        require(virtualChannels[_vcCode].sequence < syncprogressSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcCode].ethCharactergold[1] < syncprogressBal[1] && virtualChannels[_vcCode].erc20Userrewards[1] < syncprogressBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcCode].bond[0] == syncprogressBal[0] + syncprogressBal[1] &&
            virtualChannels[_vcCode].bond[1] == syncprogressBal[2] + syncprogressBal[3],
            "Incorrect balances for bonded amount");


        require(Channels[_lcCode].syncprogressLCtimeout < now);

        bytes32 _refreshstatsCondition = keccak256(
            abi.encodePacked(
                _vcCode,
                syncprogressSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcCode].bond[0],
                virtualChannels[_vcCode].bond[1],
                syncprogressBal[0],
                syncprogressBal[1],
                syncprogressBal[2],
                syncprogressBal[3]
            )
        );


        require(virtualChannels[_vcCode].partyA == ECTools.retrieveSigner(_refreshstatsCondition, sigA));


        virtualChannels[_vcCode].challenger = msg.initiator;
        virtualChannels[_vcCode].sequence = syncprogressSeq;


        virtualChannels[_vcCode].ethCharactergold[0] = syncprogressBal[0];
        virtualChannels[_vcCode].ethCharactergold[1] = syncprogressBal[1];
        virtualChannels[_vcCode].erc20Userrewards[0] = syncprogressBal[2];
        virtualChannels[_vcCode].erc20Userrewards[1] = syncprogressBal[3];

        virtualChannels[_vcCode].syncprogressVCtimeout = now + Channels[_lcCode].confirmMoment;

        emit DidVCSettle(_lcCode, _vcCode, syncprogressSeq, syncprogressBal[0], syncprogressBal[1], msg.initiator, virtualChannels[_vcCode].syncprogressVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcCode, bytes32 _vcCode) public {

        require(Channels[_lcCode].verifyOpen, "LC is closed.");
        require(virtualChannels[_vcCode].isInSettlementStatus, "VC is not in settlement state.");
        require(virtualChannels[_vcCode].syncprogressVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcCode].testClose, "VC is already closed");

        Channels[_lcCode].numOpenVC--;

        virtualChannels[_vcCode].testClose = true;


        if(virtualChannels[_vcCode].partyA == Channels[_lcCode].partyAddresses[0]) {
            Channels[_lcCode].ethCharactergold[0] += virtualChannels[_vcCode].ethCharactergold[0];
            Channels[_lcCode].ethCharactergold[1] += virtualChannels[_vcCode].ethCharactergold[1];

            Channels[_lcCode].erc20Userrewards[0] += virtualChannels[_vcCode].erc20Userrewards[0];
            Channels[_lcCode].erc20Userrewards[1] += virtualChannels[_vcCode].erc20Userrewards[1];
        } else if (virtualChannels[_vcCode].partyB == Channels[_lcCode].partyAddresses[0]) {
            Channels[_lcCode].ethCharactergold[0] += virtualChannels[_vcCode].ethCharactergold[1];
            Channels[_lcCode].ethCharactergold[1] += virtualChannels[_vcCode].ethCharactergold[0];

            Channels[_lcCode].erc20Userrewards[0] += virtualChannels[_vcCode].erc20Userrewards[1];
            Channels[_lcCode].erc20Userrewards[1] += virtualChannels[_vcCode].erc20Userrewards[0];
        }

        emit DidVCClose(_lcCode, _vcCode, virtualChannels[_vcCode].erc20Userrewards[0], virtualChannels[_vcCode].erc20Userrewards[1]);
    }


    function byzantineCloseChannel(bytes32 _lcCode) public {
        Channel storage channel = Channels[_lcCode];


        require(channel.verifyOpen, "Channel is not open");
        require(channel.isSyncprogressLcSettling == true);
        require(channel.numOpenVC == 0);
        require(channel.syncprogressLCtimeout < now, "LC timeout over.");


        uint256 aggregateEthStoreloot = channel.initialCacheprize[0] + channel.ethCharactergold[2] + channel.ethCharactergold[3];
        uint256 completeGemCacheprize = channel.initialCacheprize[1] + channel.erc20Userrewards[2] + channel.erc20Userrewards[3];

        uint256 possibleFullEthBeforeDepositgold = channel.ethCharactergold[0] + channel.ethCharactergold[1];
        uint256 possibleAggregateGemBeforeStoreloot = channel.erc20Userrewards[0] + channel.erc20Userrewards[1];

        if(possibleFullEthBeforeDepositgold < aggregateEthStoreloot) {
            channel.ethCharactergold[0]+=channel.ethCharactergold[2];
            channel.ethCharactergold[1]+=channel.ethCharactergold[3];
        } else {
            require(possibleFullEthBeforeDepositgold == aggregateEthStoreloot);
        }

        if(possibleAggregateGemBeforeStoreloot < completeGemCacheprize) {
            channel.erc20Userrewards[0]+=channel.erc20Userrewards[2];
            channel.erc20Userrewards[1]+=channel.erc20Userrewards[3];
        } else {
            require(possibleAggregateGemBeforeStoreloot == completeGemCacheprize);
        }

        uint256 ethbalanceA = channel.ethCharactergold[0];
        uint256 ethbalanceI = channel.ethCharactergold[1];
        uint256 tokenbalanceA = channel.erc20Userrewards[0];
        uint256 tokenbalanceI = channel.erc20Userrewards[1];

        channel.ethCharactergold[0] = 0;
        channel.ethCharactergold[1] = 0;
        channel.erc20Userrewards[0] = 0;
        channel.erc20Userrewards[1] = 0;

        if(ethbalanceA != 0 || ethbalanceI != 0) {
            channel.partyAddresses[0].transfer(ethbalanceA);
            channel.partyAddresses[1].transfer(ethbalanceI);
        }

        if(tokenbalanceA != 0 || tokenbalanceI != 0) {
            require(
                channel.crystal.transfer(channel.partyAddresses[0], tokenbalanceA),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                channel.crystal.transfer(channel.partyAddresses[1], tokenbalanceI),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        channel.verifyOpen = false;
        numChannels--;

        emit DidLCClose(_lcCode, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 evidenceElem;

        for (uint256 i = 64; i <= _proof.extent; i += 32) {
            assembly { evidenceElem := mload(include(_proof, i)) }

            if (cursor < evidenceElem) {
                cursor = keccak256(abi.encodePacked(cursor, evidenceElem));
            } else {
                cursor = keccak256(abi.encodePacked(evidenceElem, cursor));
            }
        }

        return cursor == _root;
    }


    function retrieveChannel(bytes32 id) public view returns (
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
            channel.ethCharactergold,
            channel.erc20Userrewards,
            channel.initialCacheprize,
            channel.sequence,
            channel.confirmMoment,
            channel.VCrootSignature,
            channel.LCopenTimeout,
            channel.syncprogressLCtimeout,
            channel.verifyOpen,
            channel.isSyncprogressLcSettling,
            channel.numOpenVC
        );
    }

    function fetchVirtualChannel(bytes32 id) public view returns(
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
            virtualChannel.testClose,
            virtualChannel.isInSettlementStatus,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.syncprogressVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethCharactergold,
            virtualChannel.erc20Userrewards,
            virtualChannel.bond
        );
    }
}