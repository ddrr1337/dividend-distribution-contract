// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DividendERC20 is ERC20, Ownable {
    address public activeTokenAddress;
    address public tester;


    /////////////DIVIDND VARIABLES////////////////////
    struct UserAccounts {
        uint256 unclaimedBalance;
        uint256 lastDividendPoints;
    }
    mapping(address => UserAccounts) public userAccounts; //user Address => to user dividend data
    uint256 public pointMultipliyer = 10 ** 18;
    uint256 public totalDividendPoints;



    constructor(
         address _activeTokenAddress
    
        ) ERC20("Dividend Token", "DIV") {
        activeTokenAddress = _activeTokenAddress; 
    }


    //IMPLEMENT YOUR OWN MINT FUNC, BUT REMEMBER TO UPDATE DIVIDENDS BEFORE MINT
    function mint(address to, uint256 amount) public {

    // UPADATE DIVIDENDS BEFORE MINT
        userAccounts[to]
            .lastDividendPoints = totalDividendPoints;
        _mint(to, amount);
    }


    ///////////////////////////DIVIDENDS//////////////////////////
    function _dividendsOwing(address account) internal view returns (uint256) {
        uint256 newDividendPoints = totalDividendPoints -
            userAccounts[account].lastDividendPoints;
        uint256 owning = (balanceOf(account) * newDividendPoints) /
            pointMultipliyer;

        return owning;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _updateDividends(msg.sender, to);
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _updateDividends(from, to);
        _transfer(from, to, amount);
        return true;
    }

    function _updateDividends(address from, address to) internal {
        uint256 owingFrom = _dividendsOwing(from);
        uint256 owingTo = _dividendsOwing(to);

        if (owingFrom > 0) {
            userAccounts[from]
                .unclaimedBalance += owingFrom;
            userAccounts[from]
                .lastDividendPoints = totalDividendPoints;
        }
        if (owingTo > 0) {
            userAccounts[to].unclaimedBalance += owingTo;
            userAccounts[to]
                .lastDividendPoints = totalDividendPoints;
        }
        if (balanceOf(to) == 0) {
            userAccounts[to].unclaimedBalance += owingTo;
            userAccounts[to]
                .lastDividendPoints = totalDividendPoints;
        }
    }

    /////////////////CLAIM AND CHECK REWARDS /////////////////////

    function claimRewards() public {
        uint256 owing = _dividendsOwing(msg.sender);

        userAccounts[msg.sender].unclaimedBalance += owing;
        userAccounts[msg.sender]
            .lastDividendPoints = totalDividendPoints;
        uint256 userUnClaimedBalance = userAccounts[msg.sender]
            .unclaimedBalance;
        userAccounts[msg.sender].unclaimedBalance = 0;
        ERC20(activeTokenAddress).transfer(msg.sender, userUnClaimedBalance);
    }

    function checkRewards(
        address user
    ) public view returns (uint256) {
        uint256 owing = _dividendsOwing(user);
        uint256 unClaimed = userAccounts[user].unclaimedBalance +
            owing;
        return unClaimed;
    }

    ///////////////////////DEPOSIT DIVIDENDS////////////////////////
    function depositDividends(
        uint256 amount
    ) external onlyOwner {
        require(
            ERC20(activeTokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "TokenReward transfer failed"
        );
        require(
            totalSupply() > 0,
            'Total Supply is 0'
        );
       
        // YOU CAN NOT CALL THIS FUNCTION IF totalASupply() == 0
        totalDividendPoints += ((amount *
            pointMultipliyer) / totalSupply());

    }

}
