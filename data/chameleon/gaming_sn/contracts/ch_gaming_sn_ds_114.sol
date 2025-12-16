// https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

pragma solidity ^0.4.23;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Gem {
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool win);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool win);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event PermissionGranted(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {

    // @dev Recovers the address which has signed a message
    // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    function restoreSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);

        // need this for test RPC
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedSeal = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).extent != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrDestinationRaw(substring(_sig, 2, 132));
        assembly {
            r := mload(attach(sig, 32))
            s := mload(attach(sig, 64))
            v := byte(0, mload(attach(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return ecrecover(prefixedSeal, v, r, s);
    }

    // @dev Verifies if the message is signed by an address
    function testSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == restoreSigner(_hashedMsg, _sig);
    }

    // @dev Converts an hexstring to bytes
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

    // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
    function parseInt16Char(string _char) public pure returns (uint) {
        bytes memory bresult = bytes(_char);
        // bool decimals = false;
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

    // @dev Converts a uint to a bytes32
    // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
    function numberTargetBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(attach(b, 32), _uint)}
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function targetEthereumSignedCommunication(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).extent;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, numberTargetName(len), _msg));
    }

    // @dev Converts a uint in a string
    function numberTargetName(uint _uint) public pure returns (string str) {
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

    // @dev extract a substring
    // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
    function substring(string _str, uint _beginPosition, uint _closeSlot) public pure returns (string) {
        bytes memory strData = bytes(_str);
        require(_beginPosition <= _closeSlot);
        require(_beginPosition >= 0);
        require(_closeSlot <= strData.extent);

        bytes memory outcome = new bytes(_closeSlot - _beginPosition);
        for (uint i = _beginPosition; i < _closeSlot; i++) {
            outcome[i - _beginPosition] = strData[i];
        }
        return string(outcome);
    }
}
contract StandardCrystal is Gem {

    function transfer(address _to, uint256 _value) public returns (bool win) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(playerLoot[msg.caster] >= _value);
        playerLoot[msg.caster] -= _value;
        playerLoot[_to] += _value;
        emit Transfer(msg.caster, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(playerLoot[_from] >= _value && allowed[_from][msg.caster] >= _value);
        playerLoot[_to] += _value;
        playerLoot[_from] -= _value;
        allowed[_from][msg.caster] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return playerLoot[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool win) {
        allowed[msg.caster][_spender] = _value;
        emit PermissionGranted(msg.caster, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) playerLoot;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardCrystal is StandardCrystal {

    /* Public variables of the crystal */

    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.caster, _value, this, _extraDetails));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant Edition = "0.0.1";

    uint256 public numChannels = 0;

    event DidLCOpen (
        bytes32 indexed channelIdentifier,
        address indexed partyA,
        address indexed partyI,
        uint256 ethPrizecountA,
        address crystal,
        uint256 medalTreasureamountA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelIdentifier,
        uint256 ethRewardlevelI,
        uint256 coinGoldholdingI
    );

    event DidLcAddtreasure (
        bytes32 indexed channelIdentifier,
        address indexed target,
        uint256 depositGold,
        bool isCoin
    );

    event DidLcSyncprogressCondition (
        bytes32 indexed channelIdentifier,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethPrizecountA,
        uint256 medalTreasureamountA,
        uint256 ethRewardlevelI,
        uint256 coinGoldholdingI,
        bytes32 vcSource,
        uint256 updatelevelLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelIdentifier,
        uint256 sequence,
        uint256 ethPrizecountA,
        uint256 medalTreasureamountA,
        uint256 ethRewardlevelI,
        uint256 coinGoldholdingI
    );

    event DidVCInit (
        bytes32 indexed lcCode,
        bytes32 indexed vcIdentifier,
        bytes evidence,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 lootbalanceA,
        uint256 treasureamountB
    );

    event DidVCSettle (
        bytes32 indexed lcCode,
        bytes32 indexed vcIdentifier,
        uint256 updatelevelSeq,
        uint256 syncprogressBalA,
        uint256 refreshstatsBalB,
        address challenger,
        uint256 refreshstatsVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcCode,
        bytes32 indexed vcIdentifier,
        uint256 lootbalanceA,
        uint256 treasureamountB
    );

    struct Channel {
        //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
        address[2] partyAddresses; // 0: partyA 1: partyI
        uint256[4] ethBalances; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[4] erc20Balances; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[2] initialDeposit; // 0: eth 1: tokens
        uint256 sequence;
        uint256 confirmTime;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 updateLCtimeout; // when update LC times out
        bool isOpen; // true when both parties have joined
        bool isUpdateLCSettling;
        uint256 numOpenVC;
        HumanStandardToken token;
    }

    // virtual-channel state
    struct VirtualChannel {
        bool isClose;
        bool isInSettlementState;
        uint256 sequence;
        address challenger; // Initiator of challenge
        uint256 updateVCtimeout; // when update VC times out
        // channel state
        address partyA; // VC participant A
        address partyB; // VC participant B
        address partyI; // LC hub
        uint256[2] ethBalances;
        uint256[2] erc20Balances;
        uint256[2] bond;
        HumanStandardToken token;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => Channel) public Channels;

    function createChannel(
        bytes32 _lcID,
        address _partyI,
        uint256 _confirmTime,
        address _token,
        uint256[2] _balances // [eth, token]
    )
        public
        payable
    {
        require(Channels[_lcID].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");
        // Set initial ledger channel state
        // Alice must execute this and we assume the initial state
        // to be signed from this requirement
        // Alternative is to check a sig as in joinChannel
        Channels[_lcID].partyAddresses[0] = msg.sender;
        Channels[_lcID].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "Eth balance does not match sent value");
            Channels[_lcID].ethBalances[0] = msg.value;
        }
        if(_balances[1] != 0) {
            Channels[_lcID].token = HumanStandardToken(_token);
            require(Channels[_lcID].token.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcID].erc20Balances[0] = _balances[1];
        }

        Channels[_lcID].sequence = 0;
        Channels[_lcID].confirmTime = _confirmTime;
        // is close flag, lc state sequence, number open vc, vc root hash, partyA...
        //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
        Channels[_lcID].LCopenTimeout = now + _confirmTime;
        Channels[_lcID].initialDeposit = _balances;

        emit DidLCOpen(_lcID, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcID].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcID) public {
        require(msg.sender == Channels[_lcID].partyAddresses[0] && Channels[_lcID].isOpen == false);
        require(now > Channels[_lcID].LCopenTimeout);

        if(Channels[_lcID].initialDeposit[0] != 0) {
            Channels[_lcID].partyAddresses[0].transfer(Channels[_lcID].ethBalances[0]);
        }
        if(Channels[_lcID].initialDeposit[1] != 0) {
            require(Channels[_lcID].token.transfer(Channels[_lcID].partyAddresses[0], Channels[_lcID].erc20Balances[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcID, 0, Channels[_lcID].ethBalances[0], Channels[_lcID].erc20Balances[0], 0, 0);

        // only safe to delete since no action was taken on this channel
        delete Channels[_lcID];
    }

    function joinChannel(bytes32 _lcID, uint256[2] _balances) public payable {
        // require the channel is not open yet
        require(Channels[_lcID].isOpen == false);
        require(msg.sender == Channels[_lcID].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "state balance does not match sent value");
            Channels[_lcID].ethBalances[1] = msg.value;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcID].token.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcID].erc20Balances[1] = _balances[1];
        }

        Channels[_lcID].initialDeposit[0]+=_balances[0];
        Channels[_lcID].initialDeposit[1]+=_balances[1];
        // no longer allow joining functions to be called
        Channels[_lcID].isOpen = true;
        numChannels++;

        emit DidLCJoin(_lcID, _balances[0], _balances[1]);
    }

    // additive updates of monetary state
    function deposit(bytes32 _lcID, address recipient, uint256 _balance, bool isToken) public payable {
        require(Channels[_lcID].isOpen == true, "Tried adding funds to a closed channel");
        require(recipient == Channels[_lcID].partyAddresses[0] || recipient == Channels[_lcID].partyAddresses[1]);

        //if(Channels[_lcID].token)

        if (Channels[_lcID].partyAddresses[0] == recipient) {
            if(isToken) {
                require(Channels[_lcID].token.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcID].erc20Balances[2] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcID].ethBalances[2] += msg.value;
            }
        }

        if (Channels[_lcID].partyAddresses[1] == recipient) {
            if(isToken) {
                require(Channels[_lcID].token.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcID].erc20Balances[3] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcID].ethBalances[3] += msg.value;
            }
        }

        emit DidLCDeposit(_lcID, recipient, _balance, isToken);
    }

    // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
    function consensusCloseChannel(
        bytes32 _lcID,
        uint256 _sequence,
        uint256[4] _balances, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _sigA,
        string _sigI
    )
        public
    {
        // assume num open vc is 0 and root hash is 0x0
        //require(Channels[_lcID].sequence < _sequence);
        require(Channels[_lcID].isOpen == true);
        uint256 totalEthDeposit = Channels[_lcID].initialDeposit[0] + Channels[_lcID].ethBalances[2] + Channels[_lcID].ethBalances[3];
        uint256 totalTokenDeposit = Channels[_lcID].initialDeposit[1] + Channels[_lcID].erc20Balances[2] + Channels[_lcID].erc20Balances[3];
        require(totalEthDeposit == _balances[0] + _balances[1]);
        require(totalTokenDeposit == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcID,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcID].partyAddresses[0],
                Channels[_lcID].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcID].partyAddresses[0] == ECTools.recoverSigner(_state, _sigA));
        require(Channels[_lcID].partyAddresses[1] == ECTools.recoverSigner(_state, _sigI));

        Channels[_lcID].isOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcID].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcID].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcID].token.transfer(Channels[_lcID].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcID].token.transfer(Channels[_lcID].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcID, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }

    // Byzantine functions

    function updateLCstate(
        bytes32 _lcID,
        uint256[6] updateParams, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        Channel storage channel = Channels[_lcID];
        require(channel.isOpen);
        require(channel.sequence < updateParams[0]); // do same as vc sequence check
        require(channel.ethBalances[0] + channel.ethBalances[1] >= updateParams[2] + updateParams[3]);
        require(channel.erc20Balances[0] + channel.erc20Balances[1] >= updateParams[4] + updateParams[5]);

        if(channel.isUpdateLCSettling == true) {
            require(channel.updateLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcID,
                false,
                updateParams[0],
                updateParams[1],
                _VCroot,
                channel.partyAddresses[0],
                channel.partyAddresses[1],
                updateParams[2],
                updateParams[3],
                updateParams[4],
                updateParams[5]
            )
        );

        require(channel.partyAddresses[0] == ECTools.recoverSigner(_state, _sigA));
        require(channel.partyAddresses[1] == ECTools.recoverSigner(_state, _sigI));

        // update LC state
        channel.sequence = updateParams[0];
        channel.numOpenVC = updateParams[1];
        channel.ethBalances[0] = updateParams[2];
        channel.ethBalances[1] = updateParams[3];
        channel.erc20Balances[0] = updateParams[4];
        channel.erc20Balances[1] = updateParams[5];
        channel.VCrootHash = _VCroot;
        channel.isUpdateLCSettling = true;
        channel.updateLCtimeout = now + channel.confirmTime;

        // make settlement flag

        emit DidLCUpdateState (
            _lcID,
            updateParams[0],
            updateParams[1],
            updateParams[2],
            updateParams[3],
            updateParams[4],
            updateParams[5],
            _VCroot,
            channel.updateLCtimeout
        );
    }

    // supply initial state of VC to "prime" the force push game
    function initVCstate(
        bytes32 _lcID,
        bytes32 _vcID,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string sigA
    )
        public
    {
        require(Channels[_lcID].isOpen, "LC is closed.");
        // sub-channel must be open
        require(!virtualChannels[_vcID].isClose, "VC is closed.");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        require(Channels[_lcID].updateLCtimeout < now, "LC timeout not over.");
        // prevent rentry of initializing vc state
        require(virtualChannels[_vcID].updateVCtimeout == 0);
        // partyB is now Ingrid
        bytes32 _initState = keccak256(
            abi.encodePacked(_vcID, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );

        // Make sure Alice has signed initial vc state (A/B in oldState)
        require(_partyA == ECTools.recoverSigner(_initState, sigA));

        // Check the oldState is in the root hash
        require(_isContained(_initState, _proof, Channels[_lcID].VCrootHash) == true);

        virtualChannels[_vcID].partyA = _partyA; // VC participant A
        virtualChannels[_vcID].partyB = _partyB; // VC participant B
        virtualChannels[_vcID].sequence = uint256(0);
        virtualChannels[_vcID].ethBalances[0] = _balances[0];
        virtualChannels[_vcID].ethBalances[1] = _balances[1];
        virtualChannels[_vcID].erc20Balances[0] = _balances[2];
        virtualChannels[_vcID].erc20Balances[1] = _balances[3];
        virtualChannels[_vcID].bond = _bond;
        virtualChannels[_vcID].updateVCtimeout = now + Channels[_lcID].confirmTime;
        virtualChannels[_vcID].isInSettlementState = true;

        emit DidVCInit(_lcID, _vcID, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }

    //TODO: verify state transition since the hub did not agree to this state
    // make sure the A/B balances are not beyond ingrids bonds
    // Params: vc init state, vc final balance, vcID
    function settleVC(
        bytes32 _lcID,
        bytes32 _vcID,
        uint256 updateSeq,
        address _partyA,
        address _partyB,
        uint256[4] updateBal, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
        string sigA
    )
        public
    {
        require(Channels[_lcID].isOpen, "LC is closed.");
        // sub-channel must be open
        require(!virtualChannels[_vcID].isClose, "VC is closed.");
        require(virtualChannels[_vcID].sequence < updateSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcID].ethBalances[1] < updateBal[1] && virtualChannels[_vcID].erc20Balances[1] < updateBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcID].bond[0] == updateBal[0] + updateBal[1] &&
            virtualChannels[_vcID].bond[1] == updateBal[2] + updateBal[3],
            "Incorrect balances for bonded amount");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
        // fail if initVC() isn't called first
        // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
        require(Channels[_lcIdentifier].updatelevelLCtimeout < now); // for testing!

        bytes32 _updatelevelCondition = keccak256(
            abi.encodePacked(
                _vcIdentifier,
                updatelevelSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcIdentifier].bond[0],
                virtualChannels[_vcIdentifier].bond[1],
                updatelevelBal[0],
                updatelevelBal[1],
                updatelevelBal[2],
                updatelevelBal[3]
            )
        );

        // Make sure Alice has signed a higher sequence new state
        require(virtualChannels[_vcIdentifier].partyA == ECTools.restoreSigner(_updatelevelCondition, sigA));

        // store VC data
        // we may want to record who is initiating on-chain settles
        virtualChannels[_vcIdentifier].challenger = msg.caster;
        virtualChannels[_vcIdentifier].sequence = updatelevelSeq;

        // channel state
        virtualChannels[_vcIdentifier].ethCharactergold[0] = updatelevelBal[0];
        virtualChannels[_vcIdentifier].ethCharactergold[1] = updatelevelBal[1];
        virtualChannels[_vcIdentifier].erc20Playerloot[0] = updatelevelBal[2];
        virtualChannels[_vcIdentifier].erc20Playerloot[1] = updatelevelBal[3];

        virtualChannels[_vcIdentifier].refreshstatsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;

        emit DidVCSettle(_lcIdentifier, _vcIdentifier, updatelevelSeq, updatelevelBal[0], updatelevelBal[1], msg.caster, virtualChannels[_vcIdentifier].refreshstatsVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcIdentifier, bytes32 _vcIdentifier) public {
        // require(updateLCtimeout > now)
        require(Channels[_lcIdentifier].validateOpen, "LC is closed.");
        require(virtualChannels[_vcIdentifier].isInSettlementCondition, "VC is not in settlement state.");
        require(virtualChannels[_vcIdentifier].refreshstatsVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcIdentifier].checkClose, "VC is already closed");
        // reduce the number of open virtual channels stored on LC
        Channels[_lcIdentifier].numOpenVC--;
        // close vc flags
        virtualChannels[_vcIdentifier].checkClose = true;
        // re-introduce the balances back into the LC state from the settled VC
        // decide if this lc is alice or bob in the vc
        if(virtualChannels[_vcIdentifier].partyA == Channels[_lcIdentifier].partyAddresses[0]) {
            Channels[_lcIdentifier].ethCharactergold[0] += virtualChannels[_vcIdentifier].ethCharactergold[0];
            Channels[_lcIdentifier].ethCharactergold[1] += virtualChannels[_vcIdentifier].ethCharactergold[1];

            Channels[_lcIdentifier].erc20Playerloot[0] += virtualChannels[_vcIdentifier].erc20Playerloot[0];
            Channels[_lcIdentifier].erc20Playerloot[1] += virtualChannels[_vcIdentifier].erc20Playerloot[1];
        } else if (virtualChannels[_vcIdentifier].partyB == Channels[_lcIdentifier].partyAddresses[0]) {
            Channels[_lcIdentifier].ethCharactergold[0] += virtualChannels[_vcIdentifier].ethCharactergold[1];
            Channels[_lcIdentifier].ethCharactergold[1] += virtualChannels[_vcIdentifier].ethCharactergold[0];

            Channels[_lcIdentifier].erc20Playerloot[0] += virtualChannels[_vcIdentifier].erc20Playerloot[1];
            Channels[_lcIdentifier].erc20Playerloot[1] += virtualChannels[_vcIdentifier].erc20Playerloot[0];
        }

        emit DidVCClose(_lcIdentifier, _vcIdentifier, virtualChannels[_vcIdentifier].erc20Playerloot[0], virtualChannels[_vcIdentifier].erc20Playerloot[1]);
    }

    // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
    function byzantineCloseChannel(bytes32 _lcIdentifier) public {
        Channel storage channel = Channels[_lcIdentifier];

        // check settlement flag
        require(channel.validateOpen, "Channel is not open");
        require(channel.isUpdatelevelLcSettling == true);
        require(channel.numOpenVC == 0);
        require(channel.updatelevelLCtimeout < now, "LC timeout over.");

        // if off chain state update didnt reblance deposits, just return to deposit owner
        uint256 completeEthStoreloot = channel.initialStoreloot[0] + channel.ethCharactergold[2] + channel.ethCharactergold[3];
        uint256 combinedMedalStoreloot = channel.initialStoreloot[1] + channel.erc20Playerloot[2] + channel.erc20Playerloot[3];

        uint256 possibleFullEthBeforeCacheprize = channel.ethCharactergold[0] + channel.ethCharactergold[1];
        uint256 possibleCombinedCoinBeforeAddtreasure = channel.erc20Playerloot[0] + channel.erc20Playerloot[1];

        if(possibleFullEthBeforeCacheprize < completeEthStoreloot) {
            channel.ethCharactergold[0]+=channel.ethCharactergold[2];
            channel.ethCharactergold[1]+=channel.ethCharactergold[3];
        } else {
            require(possibleFullEthBeforeCacheprize == completeEthStoreloot);
        }

        if(possibleCombinedCoinBeforeAddtreasure < combinedMedalStoreloot) {
            channel.erc20Playerloot[0]+=channel.erc20Playerloot[2];
            channel.erc20Playerloot[1]+=channel.erc20Playerloot[3];
        } else {
            require(possibleCombinedCoinBeforeAddtreasure == combinedMedalStoreloot);
        }

        uint256 ethbalanceA = channel.ethCharactergold[0];
        uint256 ethbalanceI = channel.ethCharactergold[1];
        uint256 tokenbalanceA = channel.erc20Playerloot[0];
        uint256 tokenbalanceI = channel.erc20Playerloot[1];

        channel.ethCharactergold[0] = 0;
        channel.ethCharactergold[1] = 0;
        channel.erc20Playerloot[0] = 0;
        channel.erc20Playerloot[1] = 0;

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

        channel.validateOpen = false;
        numChannels--;

        emit DidLCClose(_lcIdentifier, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 verificationElem;

        for (uint256 i = 64; i <= _proof.extent; i += 32) {
            assembly { verificationElem := mload(attach(_proof, i)) }

            if (cursor < verificationElem) {
                cursor = keccak256(abi.encodePacked(cursor, verificationElem));
            } else {
                cursor = keccak256(abi.encodePacked(verificationElem, cursor));
            }
        }

        return cursor == _root;
    }

    //Struct Getters
    function acquireChannel(bytes32 id) public view returns (
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
            channel.erc20Playerloot,
            channel.initialStoreloot,
            channel.sequence,
            channel.confirmInstant,
            channel.VCrootSignature,
            channel.LCopenTimeout,
            channel.updatelevelLCtimeout,
            channel.validateOpen,
            channel.isUpdatelevelLcSettling,
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
            virtualChannel.isInSettlementCondition,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.refreshstatsVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethCharactergold,
            virtualChannel.erc20Playerloot,
            virtualChannel.bond
        );
    }
}