//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

interface EventsInterface {
    event Router(address indexed router, address indexed contractAddress);
    event Registry(address indexed factory, address indexed contractAddress);
    event Factory(address indexed registry, address indexed contractAddress);
    event FeeContract(address indexed feeContract, address indexed contractAddress);
    event FeeParameters( uint256 _swapFee, uint256 _protocolPerformanceFee, address indexed _protocolPerformanceFeeRecipient, uint256 _feeDecimals);
    event Initializes(address indexed pair, address indexed token0, address indexed token1);
    event Liquidity(address from, address indexed token0DepositedAddress, address indexed token1DepositedAddress, uint256 amoutOfLpTokensReceived);
    event LiquidityRouter(address indexed sender , uint256 token0DepositedAmount, uint256 token1DepositedAmount);
    event LiquidityRouterRemove(address indexed sender , uint256 amontOfLptokens, address token0ToReceive, address token1toReceive);
    event SwapedInRouter(address indexed _tokenIn, address indexed _tokenOut, uint256 _amountIn, uint256 _minAmountOut, address indexed recipient);
    event SwapedOutRouter(address indexed _tokenIn, address indexed _tokenOut, uint256 _amountOut, uint256 _maxAmountOut, address indexed recipient);
    event RemovedLiquidity(
        address from,
        address indexed to,
        uint256 amoutOfLpTokensRemoved,
        address indexed token0ReceivedAddress,
        address indexed token1DepositedAddress,
        uint256 token0ReceivedAmount,
        uint256 token1ReceivedAmount
    );
    event SwapedIn(address indexed tokenIn, uint256 amountIn, address indexed tokenOut, uint tokenOutAmount, address indexed recipient);
    event SwapedOut(address indexed tokenIn, uint256 amountIn, address indexed tokenOut, uint tokenOutAmount, address indexed recipient);
    event NewPair(address indexed token0, address indexed token1, address indexed pair);
}