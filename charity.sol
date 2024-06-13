// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CharityToken is ERC20 {
    address public owner;
    uint256 public tokenRate = 10; // 10 tokens per 1 BNB
    uint256 public totalDonatedBNB;
    uint256 public totalMintedTokens;

    event Donation(address indexed donor, uint256 amountBNB, uint256 amountTokens);
    event TokenReceived(address indexed token, address indexed sender, uint256 amount);
    event TokenWithdrawn(address indexed token, address indexed recipient, uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    constructor() ERC20("CharityToken", "CHT") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to donate BNB and receive tokens in return
    function donate() external payable {
        require(msg.value > 0, "Invalid donation amount");
        
        uint256 tokenAmount = msg.value * tokenRate;

        _mint(msg.sender, tokenAmount);
        totalDonatedBNB += msg.value;
        totalMintedTokens += tokenAmount;

        emit Donation(msg.sender, msg.value, tokenAmount);
    }

    // Function to change the token rate (only callable by the owner)
    function changeTokenRate(uint256 _newRate) external onlyOwner {
        tokenRate = _newRate;
    }

    // Function to withdraw BNB from the contract (only callable by the owner)
    function withdrawBNB(address payable _recipient, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient BNB balance");
        _recipient.transfer(_amount);
        emit Withdrawn(_recipient, _amount);
    }

    // Function to withdraw contract's own tokens (only callable by the owner)
    function withdrawContractTokens(uint256 _amount) external onlyOwner {
        require(balanceOf(address(this)) >= _amount, "Insufficient token balance");
        _transfer(address(this), owner, _amount);
    }

    // Function to receive approval and deposit tokens
    function receiveTokens(address _token, uint256 _amount) external {
        IERC20 token = IERC20(_token);
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        emit TokenReceived(_token, msg.sender, _amount);
    }

    // Function to withdraw tokens (only callable by the owner)
    function withdrawExternalTokens(address _token, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.transfer(owner, _amount), "Token transfer failed");
        emit TokenWithdrawn(_token, owner, _amount);
    }

    // Function to change the owner of the contract
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner address");
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    // Function to receive ETH
    receive() external payable {
        require(msg.value > 0, "Invalid donation amount");
        
        uint256 tokenAmount = msg.value * tokenRate;

        _mint(msg.sender, tokenAmount);
        totalDonatedBNB += msg.value;
        totalMintedTokens += tokenAmount;

        emit Donation(msg.sender, msg.value, tokenAmount);
    }
}
