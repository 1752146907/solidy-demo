// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract TokenStaking {

    struct StakeInfo {
        uint256 amount;    
        uint256 startTime; 
    }

    IERC20 public stakingToken;

    mapping(address => StakeInfo) public stakes;

    uint256 public constant APR = 100; // 年化 100%

    constructor(address _token) {
        stakingToken = IERC20(_token);
    }

    /// @notice 质押代币
    function stake(uint256 amount) external {
        require(amount > 0, "amount = 0");

        StakeInfo storage s = stakes[msg.sender];

        // 先把老奖励算好
        if (s.amount > 0) {
            uint256 reward = pendingReward(msg.sender);
            s.amount += reward;
        }

        // 把代币转进来
        require(
            stakingToken.transferFrom(msg.sender, address(this), amount),
            "transfer failed"
        );

        s.amount += amount;
        s.startTime = block.timestamp;
    }

    /// @notice 计算奖励
    function pendingReward(address user) public view returns (uint256) {
        StakeInfo memory s = stakes[user];
        if (s.amount == 0) return 0;

        uint256 duration = block.timestamp - s.startTime;

        // 奖励公式：
        // amount * APR / 100 * duration / 365天
        return s.amount * APR * duration / 365 days / 100;
    }

    /// @notice 领取奖励
    function claimReward() external {
        StakeInfo storage s = stakes[msg.sender];
        require(s.amount > 0, "no stake");

        uint256 reward = pendingReward(msg.sender);
        require(reward > 0, "no reward");

        s.startTime = block.timestamp;

        require(stakingToken.transfer(msg.sender, reward), "reward fail");
    }

    /// @notice 退出质押 + 取回本金
    function withdraw() external {
        StakeInfo storage s = stakes[msg.sender];
        require(s.amount > 0, "no stake");

        uint256 reward = pendingReward(msg.sender);
        uint256 amount = s.amount;

        s.amount = 0;

        require(stakingToken.transfer(msg.sender, amount + reward), "withdraw fail");
    }
}
