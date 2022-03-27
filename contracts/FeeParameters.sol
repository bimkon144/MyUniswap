//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import '../interface/EventsInterface.sol';

contract FeeParameters is Ownable, EventsInterface {
    uint256 public swapFee;
    uint256 public protocolPerformanceFee;
    address public protocolPerformanceFeeRecipient;
    uint256 public feeDecimals;


    function setFeeParamseters(
        uint256 _swapFee,
        uint256 _protocolPerformanceFee,
        address _protocolPerformanceFeeRecipient,
        uint256 _feeDecimals
    ) external onlyOwner {
        swapFee = _swapFee;
        protocolPerformanceFee = _protocolPerformanceFee;
        protocolPerformanceFeeRecipient = _protocolPerformanceFeeRecipient;
        feeDecimals = _feeDecimals;
        emit FeeParameters(_swapFee, _protocolPerformanceFee, _protocolPerformanceFeeRecipient, _feeDecimals);
    }
}