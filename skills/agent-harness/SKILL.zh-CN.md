---
name: agent-harness
description: 当用户明确要求运行 agent-harness、harness engineering、长时间作业、高级交付、单 agent harness、Planner-Generator-Evaluator、规划器/生成器/评估器，要求唤醒 harness 处理具体需求，或明确要求质检/改进 agent-harness skill 自身时使用。显式启动意味着委托交付结果，而不是让 Codex 机械执行字面最小动作。本文件是中文阅读版；可安装版本以 SKILL.md 为准。
---

# Agent Harness 中文阅读版

## 核心模型

运行一个单 agent harness，内部包含三个隔离角色轮次：

1. Planner / 规划者
2. Generator / 生成者
3. Evaluator / 评估者

宿主助手是 Coordinator / 协调者。Coordinator 不属于三个角色轮次之一。它负责组织流程、用户沟通、工具边界、最终综合，以及遵守当前环境的系统/仓库/安全指令。

默认不需要多个模型、外部 CLI 或子任务 worker。质量收益来自角色分离、文件交接、严格评估、迭代合同、checkpoint 和验证。默认和 canonical 形态是一个 agent 按顺序运行隔离角色轮次。

## 启动语义

当用户明确启动这个 skill 处理一个具体任务时，Coordinator 应把它理解为“用户委托一个结果”，而不是“用户要求做字面最小动作”。

Coordinator 需要负责把短 prompt 转成可交付目标：

- 推断用户真正想要的结果。
- 把需求扩展成产品/任务规格。
- 在低风险、可逆的地方主动做合理假设。
- 只在会改变范围、风险、权限、预算或外部承诺的阻断性问题上询问用户。
- 把大任务拆成 milestone、contract 和验证门。
- 持续推进，直到当前合同通过、触发停止条件，或遇到必须交给用户的真实 blocker。
- 最终交付验证证据，而不是只给自信总结。

启动不等于无限扩范围。它只授权在用户目标、系统约束、仓库规则和 autonomy budget 内主动承担交付责任。

## 不可协商原则

- 生成和评估必须分离。Generator 的自评不能作为最终质量门。
- Planner 只定义应当存在什么，不提前规定所有实现细节。
- 尽量使用文件交接。一个角色写 artifact，另一个角色读取并回应。
- 每个构建周期前必须有 iteration contract；简化模式下必须有 final review contract。
- Evaluator 必须严格，并在任务允许时主动检查、运行、点击、复现、验证。
- 优先自主推进，而不是频繁提问。只有阻断安全或有效推进的问题才问用户。
- 对明确的长作业/高级交付请求，优先完整、验证过的结果，而不是短响应延迟。
- 每个 harness 组件都代表一个假设。未来模型更强时，可以一次移除或简化一个组件，并比较结果。

## 四个角色

### Coordinator / 协调者

Coordinator 负责保存用户意图、应用系统/组织/仓库约束、选择交付模式、设定 autonomy budget、记录提问策略和停止条件、创建私有交接空间并写入 `00-request.md`、控制角色边界、防止写入冲突、释放已完成会话/临时状态资源，并决定是否继续迭代、接受残余风险或询问用户。

短任务、标准交付和只评审模式可以使用临时交接空间，默认路径为 `${TMPDIR:-/tmp}/agent-harness-<task-slug>-<timestamp>/`。长作业必须使用持久交接空间，避免 checkpoint 因 App 重启、上下文压缩、系统清理临时目录或手动暂停而丢失。只有在仓库内私有交接文件可接受且会被忽略时，才优先使用 `<repo>/.agent-harness/<task-slug>/`；否则使用 `${CODEX_HOME:-$HOME/.codex}/harness-runs/<task-slug>-<timestamp>/` 或其他用户拥有的持久目录。

### Planner / 规划者

Planner 把用户需求扩展成高层产品/任务规格：

- 目标
- 用户
- 范围
- 非目标
- 约束
- milestone 或 vertical slice（适用于长作业）
- 风险
- 验收标准

Planner 写 `10-product-spec.md`。它不能提前绑定脆弱技术方案，不能直接实现，也不能判断最终质量。

### Generator / 生成者

Generator 负责实际产出。它必须读取 `10-product-spec.md` 和当前 `25-iteration-contract.md`；在简化模式下读取 `25-final-review-contract.md`。

Generator 只实现合同内的范围。它可以自检，但自检只是初步检查。它需要报告变更文件/产物、关键决策、验证命令、自评结果和已知限制。

### Evaluator / 评估者

Evaluator 是严格的独立裁判。它负责建立评估 rubric、协商合同、独立验证结果，并输出 findings first 的评估报告。

在单 agent 模式下，Evaluator 必须先看直接证据，再看 Generator 报告。第一轮只读取 `10-product-spec.md`、当前合同、实际变更文件/产物、diff、日志、截图、测试输出或渲染结果，并先根据这些证据草拟 findings。之后再读取 `30-generation-report.md`，只用于核对文件列表、验证声明、已知限制和遗漏。

Evaluator 不能接受 Generator 自评作为证据，不能让 Generator 报告框定第一轮判断，不能为了礼貌牺牲准确性，也不能直接修复产物，除非 Coordinator 明确改变它的角色。

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

## 交付模式

根据用户意图选择最轻但足够可靠的模式。用户显式启动 agent-harness 但没有指定模式时，默认使用标准交付；如果任务明显较大、模糊、高价值，或用户要求高级产物，则使用长作业交付。

### Standard Delivery / 标准交付

适合具体但仍需要规划和验收的任务：

- 扩展需求成规格。
- 跑一轮聚焦合同。
- 验证结果。
- 只有 blocking issue 存在时才迭代。

### Long-Job Delivery / 长作业交付

适合用户希望 agent 深入思考、长时间工作、主动补全需求并产出高级结果的任务。

使用长作业交付时，读取 `references/long-job-checklist.md`，并把它作为 Coordinator 的进度清单。

长作业交付必须包含：

- 带 milestone 或 vertical slice 的产品/任务规格。
- `00-request.md` 中的 autonomy budget 和 question policy。
- `00-request.md` 中记录的持久交接空间。
- 构建前明确 stop condition。
- 每个合同周期结束后的 checkpoint 式进展记录。
- 每个完成 milestone 的验证证据。
- 当 Generator 失去连贯性、重复失败或接近运行时上下文极限时，使用 context transition。

milestone 之间默认继续推进；只有阻断性歧义、风险、权限问题或停止条件触发时才询问用户。

## Stall and Resume Policy / 卡住与恢复策略

长作业不能变成无限硬冲。Coordinator 必须识别卡住信号并选择恢复路径。

以下情况视为卡住信号：

- 同一个实质失败连续出现两次。
- 验证连续失败两次，但诊断没有变清楚。
- Generator 重复之前的方案，却没有新证据。
- 当前合同太模糊，无法验收。
- 输出范围超出合同。
- 上下文状态混乱、矛盾或过重。
- 工具/运行时失败阻止有效推进。

出现卡住信号时：

1. 停止继续硬冲同一个方案。
2. 写入或刷新 `45-checkpoint.md`，记录当前状态、证据、失败尝试和下一步建议。
3. 如果问题是范围不清，把当前合同标记为 `BLOCKED`，只问用户最小必要问题。
4. 如果问题是实现失败，缩小下一个合同或拆分 milestone。
5. 如果问题是上下文/状态退化，写 `35-context-transition.md`，并在运行时允许时启动新的角色轮次。
6. 如果无法验证，把验证缺口记录为残余风险，不要假装通过。

中断、上下文压缩或手动暂停后，从最新的持久 `45-checkpoint.md` 恢复。优先从下一个合同边界恢复，不要回放长聊天记录。

### Review-Only / 只评审

当用户要求 review、QA、质检或检查现有工作时使用。除非 Coordinator 明确分配修复，否则不启用 Generator 写入。

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
45-checkpoint.md（长作业 checkpoint）
50-final-summary.md
```

具体 artifact 模板见 `references/artifact-templates.md`。Coordinator 起步清单见 `references/bootstrap-checklist.md`。

`00-request.md` 应记录 intent expansion、delivery mode、handoff workspace path、autonomy budget、question policy 和 stop conditions。`10-product-spec.md` 在长作业中应记录 milestones / vertical slices。长作业的 `45-checkpoint.md` 应保留到最终交付不再需要恢复证据，或用户明确要求删除为止。

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

当 Generator 轮次出现上下文耗尽、过早收尾、状态丢失或反复失败时，不要只依赖记忆继续硬撑。应尽量启动新的 Generator 轮次，并交接 `35-context-transition.md`。

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

`SKILL.md` 是可安装的核心版本。平台 metadata、manifest、UI chip、安装目录只是适配层，不定义方法本身。其他运行环境只要能映射角色轮次、文件、工具和顺序执行，就可以使用这套协议。
