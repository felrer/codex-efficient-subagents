# Codex Efficient Subagents

Codex의 작업 위임과 중복 탐색을 줄이기 위한 프롬프트와 subagent 설정입니다. 작은 작업은 직접 처리하고, 독립적인 작업만 나눠 맡기는 방식입니다.

## 구성

| 파일 | 용도 |
|---|---|
| [AGENTS.snippet.md](instructions/AGENTS.snippet.md) | 작업 위임, 맥락 전달, 결과 통합 지침 |
| [luna_explorer.toml](agents/luna_explorer.toml) | 코드 탐색과 근거 수집 |
| [sol_executor.toml](agents/sol_executor.toml) | 구현과 검증 |
| [config.example.toml](config.example.toml) | subagent 활성화와 동시 실행 한도 |
| [delegation.md](examples/delegation.md) | 작업 위임 예시 |

작업 방향과 최종 판단은 메인 에이전트가 맡고, subagent는 전달받은 범위 안에서 작업합니다.

## 사용법

저장소를 내려받은 뒤 아래 파일을 기존 Codex 설정에 합치면 됩니다.

| 저장소 파일 | 전역 설정 위치 | 프로젝트별 설정 위치 |
|---|---|---|
| `instructions/AGENTS.snippet.md` | `~/.codex/AGENTS.md` | `AGENTS.md` |
| `agents/*.toml` | `~/.codex/agents/` | `.codex/agents/` |
| `config.example.toml` | `~/.codex/config.toml` | `.codex/config.toml` |

기존 파일은 유지하고 필요한 내용을 병합합니다. `config.toml`에 `[agents]`가 있으면 해당 항목에 합칩니다. `~`는 사용자 홈 폴더이며, `CODEX_HOME`을 따로 지정한 경우에는 그 경로를 사용합니다.

**subagent 동시 실행 한도는 8 이상을 권장합니다.**

## 모델과 추론 수준

| 역할 | 모델 | 추론 수준 |
|---|---|---|
| `luna_explorer` | `gpt-5.6-luna` | `high` |
| `sol_executor` | `gpt-5.6-sol` | `medium` |

모델과 추론 수준은 각 역할 파일의 `model`, `model_reasoning_effort`에서 변경할 수 있습니다.
