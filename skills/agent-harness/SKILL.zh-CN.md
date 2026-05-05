---
name: agent-harness
description: 当用户明确要求运行 agent-harness、harness engineering、多 agent / 子 agent、三人协作、Planner-Generator-Evaluator、规划器/生成器/评估器，要求唤醒三个 agent 处理具体需求，或明确要求质检/改进 agent-harness skill 自身时使用。本文件是中文阅读版；可安装版本以 SKILL.md 为准。
---

# Agent Harness 中文阅读版

## 核心模型

运行一个三角色 harness：

1. Planner / 规划者
2. Generator / 生成者
3. Evaluator / 评估者

宿主助手是 Coordinator / 协调者。Coordinator 不属于三个角色之一。它负责组织流程、用户沟通、工具边界、最终综合，以及遵守当前环境的系统/仓库/安全指令。

完整模式下，三个角色应尽量使用独立 agent。若运行环境不能创建子 agent，则用隔离的顺序角色轮次模拟，并明确标注这只是降级结构化评审，不是真正独立多 agent。

## 不可协商原则

- 生成和评估必须分离。Generator 的自评不能作为最终质量门。
- Planner 只定义应当存在什么，不提前规定所有实现细节。
- 尽量使用文件交接。一个角色写 artifact，另一个角色读取并回应。
- 每个构建周期前必须有 iteration contract；简化模式下必须有 final review contract。
- Evaluator 必须严格，并在任务允许时主动检查、运行、点击、复现、验证。
- 每个 harness 组件都代表一个假设。未来模型更强时，可以一次移除或简化一个组件，并比较结果。

## 四个角色

### Coordinator / 协调者

Coordinator 负责保存用户意图、应用系统/组织/仓库约束、创建私有交接空间、控制角色边界、防止写入冲突、释放已完成 agent/会话资源，并决定是否继续迭代、接受残余风险或询问用户。默认交接空间可放在 `${TMPDIR:-/tmp}/agent-harness-<task-slug>-<timestamp>/`；如果不可写，选择另一个可写临时目录。

### Planner / 规划者

Planner 把用户需求扩展成高层产品/任务规格：

- 目标
- 用户
- 范围
- 非目标
- 约束
- 风险
- 验收标准

Planner 写 `10-product-spec.md`。它不能提前绑定脆弱技术方案，不能直接实现，也不能判断最终质量。

### Generator / 生成者

Generator 负责实际产出。它必须读取 `10-product-spec.md` 和当前 `25-iteration-contract.md`；在简化模式下读取 `25-final-review-contract.md`。

Generator 只实现合同内的范围。它可以自检，但自检只是初步检查。它需要报告变更文件/产物、关键决策、验证命令、自评结果和已知限制。

### Evaluator / 评估者

Evaluator 是严格的独立裁判。它负责建立评估 rubric、协商合同、独立验证结果，并输出 findings first 的评估报告。

Evaluator 不能接受 Generator 自评作为证据，不能为了礼貌牺牲准确性，也不能直接修复产物，除非 Coordinator 明确改变它的角色。

## Iteration Contract / 迭代合同

每个构建周期前，Generator 和 Evaluator 协商 `25-iteration-contract.md`。

默认一轮只做一个功能、一个用户可见流程，或一个可测试 vertical slice。大任务拆成多轮合同，不要把无关工作塞进一轮。

握手流程：

1. Generator 根据 `10-product-spec.md` 草拟合同。
2. Evaluator 加入严格验收标准、边界情况和验证方法。
3. Generator 修订，或用证据反驳某项要求超范围、不可行、应延期。
4. 双方继续文件往返，直到 Evaluator 标记 `AGREED`。
5. Evaluator 只有在交付物和验证方式具体、可测试、对齐产品规格时，才能标记 `AGREED`。
6. Coordinator 只在工具限制、用户时间/预算限制、循环争议或范围问题时仲裁。

合同应包含：

- 本轮目标
- 交付物
- 精确验收标准
- 验证方法
- 不做事项
- 文件/产物归属
- 最大迭代次数或停止条件
- 状态：`AGREED`、`COORDINATOR-ARBITRATED` 或 `BLOCKED`
- 协商记录

## 推荐产物

```text
00-request.md
10-product-spec.md
20-evaluation-rubric.md
25-iteration-contract.md
25-final-review-contract.md
30-generation-report.md
35-context-transition.md
40-evaluation-report.md
50-final-summary.md
```

具体 artifact 模板见 `references/artifact-templates.md`。Coordinator 起步清单见 `references/bootstrap-checklist.md`。

## Rubric 默认维度

默认保留四项核心评估维度：

- 设计质量：颜色、字体、布局、层级、交互是否形成统一整体。
- 原创性：是否有任务特定决策，而不是通用模板或明显 AI 套路。
- 工艺：技术执行、一致性、对比度、可维护性和细节质量。
- 功能性：用户能否完成核心任务，核心流程是否真正可用。

根据模型短板加权。对于产品/设计任务，设计质量和原创性通常要更重，因为模型容易生成“精致但通用”的东西。工艺和功能性仍然是强制门槛：漂亮但坏掉的产品失败。

## Evaluator 校准

主观或高风险任务前，需要校准 Evaluator：

- 增加 2-5 个任务相关正例/反例。
- 把每个维度拆成具体信号。
- 明确惩罚项，例如模板化输出、无法验证的声明、缺少核心流程、一眼 AI 感。
- 要求评分解释，不只给分。
- 保留评估日志。
- 对照人类或 Coordinator 判断，找出过宽、过严、漏判、错权重之处。
- 更新 prompt、rubric、权重、few-shot 示例。
- 重新跑同一评估案例。
- 重复“读日志 -> 改 rubric/prompt -> 重跑”，直到评估足够可靠。

## Context Reset / 上下文重置

当 Generator 出现上下文耗尽、过早收尾、状态丢失或反复失败时，不要只在同一个实例里压缩摘要。应尽量启动新 Generator，并交接 `35-context-transition.md`。

交接文档包括当前目标、已完成工作、变更文件/产物、当前合同、失败检查、下一步、仍然有效的约束。

## Simplified Final Review Mode / 简化最终评审模式

只有在 Component Audit 证明当前模型/运行时可以稳定支撑更长生成时，才使用简化模式：

- 保留 Planner。
- 连续生成前冻结 `25-final-review-contract.md`。
- Generator 可以跨更大范围连续工作。
- Evaluator 从逐周期评审改为最终统一评审。
- 保持生成和评估分离，不能移除 Evaluator。
- 若最终评审发现漏范围、核心流程坏掉或质量回退，则回到完整周期模式。

## Component Audit / 组件消融

定期检验每个组件是否仍必要：

1. 命名组件和它编码的假设。
2. 一次只移除、简化或后移一个组件。
3. 用基线 harness 和修改后 harness 跑相同或相近任务。
4. 比较质量、缺陷、耗时、成本、完整性。
5. 只有质量不回退时才保留简化。
6. 如果质量下降或原因不清，恢复组件。

## 平台中立

`SKILL.md` 是可安装的核心版本。平台 metadata、manifest、UI chip、安装目录只是适配层，不定义方法本身。其他运行环境只要能映射角色、文件、工具和顺序/并行执行，就可以使用这套协议。
