pragma solidity ^0.4.2;

import "./AIBPToken.sol";

contract AIBanksPreICO {

    /*
     * External contracts
     */
    AIBPToken public aibpToken = AIBPToken(0x0);

    address public founder;

    uint256 public baseTokenPrice = 33 ether; // 33 ETH

    // participant address => value in Wei
    mapping (address => uint) public investments;

    /*
     *  Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier minInvestment() {
        // User has to send at least the ether value of one token.
        if (msg.value < baseTokenPrice) {
            throw;
        }
        _;
    }

    function fund()
        public
        minInvestment
        payable
        returns (uint)
    {
        uint tokenCount = msg.value / baseTokenPrice;
        uint investment = tokenCount * baseTokenPrice;

        if (msg.value > investment && !msg.sender.send(msg.value - investment)) {
            throw;
        }

        investments[msg.sender] += investment;
        if (!founder.send(investment)) {
            throw;
        }

        if (!aibpToken.issueTokens(msg.sender, tokenCount)) {
            throw;
        }

        return tokenCount;
    }

    function fundManually(address beneficiary, uint _tokenCount)
        external
        onlyFounder
        returns (uint)
    {
        uint investment = _tokenCount * baseTokenPrice;

        investments[beneficiary] += investment;
        
        if (!aibpToken.issueTokens(beneficiary, _tokenCount)) {
            throw;
        }

        return _tokenCount;
    }

    function setTokenAddress(address _newTokenAddress)
        external
        onlyFounder
        returns (bool)
    {
        aibpToken = AIBPToken(_newTokenAddress);
        return true;
    }

    function changeBaseTokenPrice(uint valueInWei)
        external
        onlyFounder
        returns (bool)
    {
        baseTokenPrice = valueInWei;
        return true;
    }

    function AIBanksPreICO(address _multisig) {
        founder = msg.sender;
    }

    function () payable {
        fund();
    }
}