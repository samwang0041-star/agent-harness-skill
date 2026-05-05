---
name: agent-harness
description: >-
  当用户明确要求运行 agent-harness、harness engineering、长时间作业、高级交付、单
  agent harness、Planner-Generator-Evaluator、规划器/生成器/评估器，要求唤醒 harness
  处理具体需求，或明确要求质检/改进 agent-harness skill 自身时使用。显式启动意味着委托交付结果，而不是让
  Codex 机械执行字面最小动作。本文件是中文阅读版；可安装版本以 SKILL.md 为准。
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

## 结果归属

Agent Harness 是为了产出有用结果，不是为了产出漂亮流程文档。

当启动任务绑定到真实代码库、App、文档、数据集或工作流问题时，Coordinator 在规划前必须判断最终产物类型：

- **proposal-only / 只交付方案**：用户明确只要方案、架构评审、批判、对比或决策备忘录，或实现会越过权限边界。
- **first implementation slice / 第一段可实现切片**：用户描述的是一个坏掉、薄弱、缺失或不可用的产品行为，并且当前仓库内存在安全的垂直切片可以实现。
- **full delivery / 完整交付**：任务边界足够小，可以在当前 autonomy budget 内端到端完成。

代码库修复、功能改进、产品流程、UI、文档、数据和自动化任务，默认选择 **first implementation slice**，除非用户明确说只要方案、只评审，或不要改文件。

设计方案、技术计划、架构图和路线图通常是中间产物，不是最终交付。只要有安全的下一段实现切片，就不能在写完方案后问“要不要实现”。应把下一段切片写进 iteration contract 并继续做。只有下一步会越过真实边界时才问用户：范围大幅扩张、破坏性迁移、外部副作用、成本/风险上升、访问凭证/秘密，或会显著改变结果的产品选择。

如果用户明确只要设计方案，就把方案做好，并说明下一段实现切片是什么，但不要假装产品已经被修好。

## 不可协商原则

- 生成和评估必须分离。Generator 的自评不能作为最终质量门。
- Planner 只定义应当存在什么，不提前规定所有实现细节。
- 尽量使用文件交接。一个角色写 artifact，另一个角色读取并回应。
- 每个构建周期前必须有 iteration contract；简化模式下必须有 final review contract。
- Evaluator 必须严格，并在任务允许时主动检查、运行、点击、复现、验证。
- 优先自主推进，而不是频繁提问。只有阻断安全或有效推进的问题才问用户。
- 把计划当脚手架。除非明确选择 proposal-only，否则 plan、rubric、roadmap 不是用户要的最终结果。
- 对明确的长作业/高级交付请求，优先完整、验证过的结果，而不是短响应延迟。
- 把 artifact gate 当成硬流程边界。最终回复用户前，必须确认必需交接文件存在、非空，并且 final gate 通过或已手动检查。
- 在当前 agent 会话内自监督。当前 Coordinator 负责启动、检查并服从 gate/runner/monitor 协议；不能依赖第二个助手或用户来发现 harness 提前停了。
- 每个 harness 组件都代表一个假设。未来模型更强时，可以一次移除或简化一个组件，并比较结果。

## 四个角色

### Coordinator / 协调者

Coordinator 负责保存用户意图、应用系统/组织/仓库约束、选择交付模式、判断 outcome class（只交付方案、第一段可实现切片、完整交付）、设定 autonomy budget、记录提问策略和停止条件、创建私有交接空间并写入 `00-request.md`、控制角色边界、防止写入冲突、释放已完成会话/临时状态资源，并决定是否继续迭代、接受残余风险或询问用户。final gate 通过后，必须给用户真正的最终回复；gate 输出本身不算交付。

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
- 对代码库或产品修复任务，这一轮默认必须是安全的实现切片，除非明确选择 proposal-only。
- 验证结果。
- 只有 blocking issue 存在时才迭代。

### Long-Job Delivery / 长作业交付

适合用户希望 agent 深入思考、长时间工作、主动补全需求并产出高级结果的任务。

使用长作业交付时，读取 `references/long-job-checklist.md`，并把它作为 Coordinator 的进度清单。

长作业交付必须包含：

- 带 milestone 或 vertical slice 的产品/任务规格。
- `00-request.md` 中明确 outcome class。代码库/产品修复任务默认是第一段可实现切片，除非明确只要方案。
- `00-request.md` 中的 autonomy budget 和 question policy。
- `00-request.md` 中记录的持久交接空间。
- 构建前明确 stop condition。
- 每个合同周期结束后的 checkpoint 式进展记录。
- 每个完成 milestone 的验证证据。
- 每个周期结束后通过 checkpoint gate；最终回复用户前通过 final gate。
- 当 Generator 失去连贯性、重复失败或接近运行时上下文极限时，使用 context transition。

milestone 之间默认继续推进；只有阻断性歧义、风险、权限问题或停止条件触发时才询问用户。
对于可实现任务，不能只交付 roadmap。方案通过当前 contract 后，应继续进入第一段安全 vertical slice，而不是问用户是否要实现。

## 硬门禁与轻量 Runner

这个 skill 本质是协议，但长时间工作需要一个很小的硬门禁，防止模型“代码做完就直接 final”。当运行环境能执行 shell 时，使用本 skill 目录里的 `scripts/harness-gate.sh` 作为轻量 gate。

使用任何脚本前，先解析包含本 `SKILL.md` 的绝对 skill 目录，并记录为 `HARNESS_SKILL_DIR`。不要假设当前项目目录里存在 `scripts/`。

checkpoint gate：

```bash
"$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode long-job --stage checkpoint
```

final gate：

```bash
"$HARNESS_SKILL_DIR/scripts/harness-gate.sh" --workspace "$HANDOFF_WORKSPACE" --mode long-job --stage final
```

根据实际模式选择 `--mode standard`、`--mode long-job`、`--mode simplified-final-review` 或 `--mode review-only`。
预检查 artifact 时使用 `--stage checkpoint`。只有在 `50-final-summary.md` 已经写完后，才使用 `--stage final`。

gate 失败不是小瑕疵，而是流程失败。gate 不通过时不能最终回复用户；应补齐缺失 artifact、补做验证、把合同标记为 `BLOCKED`、写入 `45-checkpoint.md`，或询问用户最小必要问题。

如果运行时不能执行 shell，则手动执行同样检查：

- 标准最终交付：`00-request.md`、`10-product-spec.md`、`20-evaluation-rubric.md`、`25-iteration-contract.md`、`30-generation-report.md`、`40-evaluation-report.md`、`50-final-summary.md`
- 长作业 checkpoint：`00-request.md`、`05-self-supervision.md`、标准 artifact 到 `40-evaluation-report.md`，再加 `45-checkpoint.md`
- 长作业最终交付：长作业 checkpoint artifact，再加 `50-final-summary.md`
- 简化最终评审：`00-request.md`、`10-product-spec.md`、`20-evaluation-rubric.md`、`25-final-review-contract.md`、`30-generation-report.md`、`40-evaluation-report.md`、`50-final-summary.md`
- 只评审最终交付：`00-request.md`、`10-product-spec.md`、`20-evaluation-rubric.md`、`40-evaluation-report.md`、`50-final-summary.md`

`40-evaluation-report.md` 必须有明确的 `PASS` 或 `FAIL`。优先使用精确标记 `Decision: PASS` 或 `Decision: FAIL`。只有自信叙述、没有 pass/fail 决策，不能通过 gate。
当前合同必须包含 `Status: AGREED`、`Status: COORDINATOR-ARBITRATED` 或 `Status: BLOCKED`；不要只靠自然语言描述。
对于产品交付模式（`standard`、`long-job`、`simplified-final-review`），final gate 必须要求 `PASS`，并且当前合同不能是 `BLOCKED`。`FAIL` 评估或 `BLOCKED` 合同可以作为 checkpoint 证据，但不是合法最终交付状态。

## 自监督协议

这个 skill 被启动后，当前 agent 必须自己监督自己。`harness-gate.sh`、`harness-runner.sh` 和 `harness-monitor.sh` 是当前 Coordinator 自己要使用的工具，不是要求另一个助手在旁边帮它盯。

每个长作业 run 都必须在开始实现前，在 handoff workspace 里创建 `05-self-supervision.md`。它必须包含：

- checkpoint 和 final 阶段的确切 `harness-gate.sh` 命令。
- 当前会话是否启动了 `harness-monitor.sh`，如果没启动，原因是什么。
- idle timeout 和最大运行时长。
- 硬规则：gate 失败时继续 harness cycle，不能最终回复用户。
- `runner-next-prompt.md`、monitor log、gate output 的位置。
- 如果运行时仍然停住，最小安全恢复指令是什么。

在 Claude Code 或任何能执行 shell 的交互式运行时中，当前 agent 应在 `00-request.md`、`10-product-spec.md`、`20-evaluation-rubric.md` 和当前合同存在后，自己启动 monitor：

```bash
nohup "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" \
  --workspace "$HANDOFF_WORKSPACE" \
  --mode long-job \
  --stage final \
  --interval 30 \
  --idle-timeout 600 \
  --cwd "$PROJECT_ROOT" \
  --request-file "$HANDOFF_WORKSPACE/00-request.md" \
  > "$HANDOFF_WORKSPACE/monitor-supervisor.log" 2>&1 &
echo $! > "$HANDOFF_WORKSPACE/monitor.pid"
sleep 2
monitor_pid="$(cat "$HANDOFF_WORKSPACE/monitor.pid")"
if ! kill -0 "$monitor_pid" 2>/dev/null; then
  echo "monitor did not stay alive; inspect monitor-supervisor.log and use checkpoint gates manually" \
    | tee -a "$HANDOFF_WORKSPACE/monitor-supervisor.log"
fi
```

启动 monitor 后必须做健康检查。如果 PID 已经不在，或者第一个轮询间隔后 monitor log 仍为空，不要声称 self-monitoring 已经生效。把 monitor 启动失败写进 `05-self-supervision.md`，然后用明确的 checkpoint/final gate 继续推进。有些嵌套 CLI 运行时会在 tool command 结束时杀掉后台任务；在这种环境里，monitor 只能算 best-effort，真正的硬约束仍然是 gate。

monitor 不能替代当前 agent 自己跑检查。当前 agent 仍然必须在每个周期结束后跑 checkpoint gate，并在最终回复用户前跑 final gate。

如果当前 agent 到达看似可以结束的位置，但 final gate 失败，它不能 final。它必须选择以下动作之一：

- 补写缺失 artifact 并重新跑 gate。
- 补做验证并更新 `40-evaluation-report.md`。
- 写入或刷新 `45-checkpoint.md`。
- 缩小下一轮合同并继续。
- 把合同标记为 `BLOCKED`，只问用户最小必要问题。

对于更长时间的无人值守任务，使用 `"$HARNESS_SKILL_DIR/scripts/harness-runner.sh"` 作为最小外部循环。runner 会检查 gate，写入 `runner-next-prompt.md`，明确下一轮缺什么；如果传入 `--agent-cmd`，它会调用指定 agent CLI 继续跑，并循环直到 gate 通过或达到最大轮数。

示例：

```bash
"$HARNESS_SKILL_DIR/scripts/harness-runner.sh" \
  --workspace "$HANDOFF_WORKSPACE" \
  --mode long-job \
  --stage final \
  --agent-cmd 'codex exec --cd "$HARNESS_CWD" "$(cat "$HARNESS_PROMPT")"' \
  --max-cycles 12
```

runner 故意保持 provider-neutral，不绑定 Codex、Claude 或 Kimi。`--agent-cmd` 可以适配当前可用 CLI。命令会收到这些环境变量：`HARNESS_WORKSPACE`、`HARNESS_MODE`、`HARNESS_STAGE`、`HARNESS_PROMPT`、`HARNESS_CWD`、`HARNESS_GATE_OUTPUT`。

对于 Claude Code 这类交互式 agent，会话自己应启动 `"$HARNESS_SKILL_DIR/scripts/harness-monitor.sh"` 作为 watchdog。monitor 会盯住 handoff workspace，重复运行 gate；gate 通过就成功退出，workspace 长时间不再变化但 gate 仍失败时，就写入 `runner-next-prompt.md`，明确告诉下一轮应该补什么。

示例：

```bash
nohup "$HARNESS_SKILL_DIR/scripts/harness-monitor.sh" \
  --workspace "$HANDOFF_WORKSPACE" \
  --mode long-job \
  --stage final \
  --interval 30 \
  --idle-timeout 600 \
  > "$HANDOFF_WORKSPACE/monitor-supervisor.log" 2>&1 &
echo $! > "$HANDOFF_WORKSPACE/monitor.pid"
```

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
05-self-supervision.md（长作业必需）
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

长作业必须在实现开始前写 `05-self-supervision.md`，记录 gate 命令、monitor 决策、idle/max duration、失败规则、日志/续跑提示位置和恢复指令。

如果运行时能执行 shell，最终交付前用 `"$HARNESS_SKILL_DIR/scripts/harness-gate.sh"` 验证这些 artifact。这个 gate 有意保持很小：只检查必需文件是否存在、非空，以及是否包含继续/审计需要的最小状态标记。

如果运行时能执行 shell 且有可用 agent CLI，当前 agent 可以用 `"$HARNESS_SKILL_DIR/scripts/harness-runner.sh"`。它是这套 skill 的最小状态机：检查、生成续跑提示、继续、过 gate、循环。

如果任务在 Claude Code 里运行，当前 Claude Code 会话应自己启动 `"$HARNESS_SKILL_DIR/scripts/harness-monitor.sh"`：监控、过 gate、识别 idle stop、生成续跑提示。

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
