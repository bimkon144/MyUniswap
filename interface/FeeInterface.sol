//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface FeeInterface {
    function setFeeParams(uint256 _swapFee, uint256 _protocolPerformanceFee, address _protocolPerformanceFeeRecipient, uint256 _feeDecimals) external;
    function swapFee() external returns (uint256);
    function protocolPerformanceFee() external returns (uint256);
    function protocolPerformanceFeeRecipient() external returns (address);
    function feeDecimals() external returns (uint256);
}