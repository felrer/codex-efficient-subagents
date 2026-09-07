# Codex Efficient Subagents

Codex에서 불필요한 위임, 맥락 전달, 중복 탐색을 줄이기 위해 사용하는 지침과 subagent 역할 설정입니다. 작은 일은 직접 처리하고, 독립적인 작업은 범위를 정해 맡기며, 결과는 근거와 함께 짧게 돌려받도록 구성했습니다.

## 공유하게 된 배경

“내가 아직 리셋 티켓을 하나밖에 쓰지 않은 이유”라는 이야기에서 출발했습니다. 제가 신경 쓴 것은 에이전트를 몇 명 쓰느냐보다, 무엇을 맡기고 무엇을 돌려받느냐였습니다. 다만 이것은 개인 사용 경험이며, 이 설정의 토큰 절감 효과를 비교 실험으로 입증한 것은 아닙니다.

원래 사용하던 환경에는 여러 스킬과 로컬 작업 방식에 최적화된 지침들이 함께 들어 있습니다. 이번에는 다른 분들이 쉽게 적용할 수 있도록 그 의존성과 개인 환경 설정을 덜어내고, subagent 운영에 필요한 부분만 간략화했습니다. **추후에는 스킬을 포함한 전체 작업 시스템을 공유할 기회가 있었으면 좋겠습니다.** 이번 공개본은 별도의 스킬 설치 없이 사용할 수 있습니다.

## 구성

| 파일 | 역할 |
|---|---|
| [AGENTS.snippet.md](instructions/AGENTS.snippet.md) | 부모의 위임 판단, 작업 전달, 결과 통합 및 공통 읽기·출력 규칙 |
| [luna_explorer.toml](agents/luna_explorer.toml) | 범위가 정해진 읽기 전용 탐색과 근거 수집 |
| [sol_executor.toml](agents/sol_executor.toml) | 동작과 범위가 합의된 구현·검증 |
| [config.example.toml](config.example.toml) | subagent 활성화와 동시 실행 한도 예시 |
| [delegation.md](examples/delegation.md) | 직접 처리·위임 판단과 작업 전달·반환 예시 |

요구사항 해석, 구조 결정, 공유 인터페이스와 최종 검수는 부모가 담당합니다. 자식은 맡은 범위에 집중하고 추가 subagent를 만들지 않습니다.

## 적용 방법

1. 이 저장소를 다운로드하거나 clone합니다.
2. `instructions/AGENTS.snippet.md` 내용을 기존 전역 `~/.codex/AGENTS.md` 또는 적용할 프로젝트의 `AGENTS.md`에 병합합니다. 같은 내용이 이미 있다면 중복을 정리합니다. 파일 전체를 덮어쓰지 마세요.
3. 역할 TOML 두 개를 전역 `~/.codex/agents/` 또는 프로젝트 `.codex/agents/`에 복사합니다. 같은 이름의 역할이 있다면 내용을 비교해 병합합니다.
4. `config.example.toml`의 설정을 전역 `~/.codex/config.toml` 또는 프로젝트 `.codex/config.toml`에 병합합니다. 기존 `[agents]`가 있으면 그 섹션의 값을 수정하고, 같은 섹션을 추가로 만들지 않습니다. 기존 `max_threads`가 있으면 중복 설정 대신 새 키로 정리합니다.
5. 새 Codex 세션에서 아래 확인 요청을 실행하고, 표시되는 역할과 모델 설정을 확인합니다. 프로젝트 설정의 로딩은 해당 프로젝트에 대한 신뢰 설정에 영향을 받을 수 있습니다.

```text
현재 적용된 AGENTS.md와 사용자 정의 subagent 역할을 확인해 주세요.
luna_explorer와 sol_executor의 책임, 모델, 추론 수준을 요약해 주세요.
아직 subagent를 실행하거나 파일을 수정하지 마세요.
```

`~`는 사용자 홈 디렉터리입니다. `CODEX_HOME`을 별도로 설정했다면 전역 경로는 그 위치를 기준으로 적용하세요. `AGENTS.override.md`가 있으면 해당 범위의 `AGENTS.md`보다 우선하므로 그 지침도 함께 확인하세요.

Codex는 역할 TOML을 `~/.codex/agents/` 또는 프로젝트 `.codex/agents/`에 복사한 뒤 해당 경로에서 발견합니다. 이 저장소의 `agents/`와 `instructions/`는 배포용 경로이므로 clone만으로 다른 프로젝트에 적용되지는 않습니다. 역할 파일에는 **사용자 정의 developer instructions**가 들어 있으며 플랫폼의 전체 시스템 프롬프트를 담은 것은 아닙니다. [공식 역할 설정 안내](https://learn.chatgpt.com/docs/agent-configuration/subagents), [AGENTS.md 안내](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

## 동시 실행 한도는 10 이상을 추천합니다

독립적인 작업을 병렬로 처리할 여유를 두기 위해 **subagent 동시 실행 한도를 적어도 10 이상으로 올리는 것을 추천합니다.** 예시 설정은 10이며, 제 개인 환경에서는 30을 사용합니다.

```toml
[agents]
enabled = true
max_concurrent_threads_per_session = 10
```

이 값은 부모를 제외하고 동시에 열 수 있는 자식 에이전트 스레드의 상한입니다. 항상 10개를 실행하거나 작업을 10개로 쪼개라는 뜻은 아닙니다. 실제 위임 수는 독립적인 작업의 수와 조정 비용에 따라 정합니다. 작은 조회나 수정은 직접 처리합니다.

10 이상이라는 권장은 이 저장소의 운영 제안이며 OpenAI의 권장 최소값이나 토큰 절감의 최적값이 아닙니다. 병렬 위임은 전체 토큰 사용량을 늘릴 수도 있습니다. [설정과 동작의 공식 설명](https://learn.chatgpt.com/docs/agent-configuration/subagents)

## 모델과 추론 수준

| 역할 | 공개본의 예시 모델 | 추론 수준 |
|---|---|---|
| `luna_explorer` | `gpt-5.6-luna` | `high` |
| `sol_executor` | `gpt-5.6-sol` | `medium` |

이는 원본의 사용값을 보존한 예시입니다. 자신의 환경에서 사용할 수 있는 모델과 지원 추론 수준으로 각 TOML의 `model`, `model_reasoning_effort`를 함께 조정하세요. 이름에 포함된 luna/sol은 역할 식별자이므로 모델만 바꿀 때 역할 이름까지 바꿀 필요는 없습니다. 역할 이름을 바꾼다면 공통 지침과 예시의 참조도 같이 수정하세요.

역할 파일에서 모델·추론 수준을 지정하므로 부모 모델을 그대로 물려받는 구성과 다를 수 있습니다. 읽기 전용 탐색은 역할 지침상의 제한이며, 쓰기를 기술적으로 차단하는 별도의 sandbox 설정은 포함하지 않습니다. 실행 권한은 적용 환경의 설정을 따릅니다.

## 원본에서 바꾼 부분

- 개인 경로, 프로젝트 전용 규칙, 별도 스킬 의존성을 제외했습니다.
- 부모와 자식의 전달 항목을 `Objective / Scope / Constraints / References / Done when / Return format`으로 통일했습니다.
- 특정 도구의 `fork_turns` 옵션을 필수 조건으로 두지 않고, 지원되는 경우 필요한 최소 이력만 전달한다는 원칙으로 정리했습니다.
- 검증은 완료 조건을 입증하는 최소 범위로 수행하되 필요한 로그와 실패 근거를 보존하도록 수정했습니다.
- 비긴급 메시지는 묶고, 다른 작업에 영향을 주는 충돌·제약 변경은 즉시 보고하도록 구분했습니다.
- 동시 실행 한도는 개인값 30에서 공개 예시 10으로 조정했습니다.

## 확인 환경과 검증 범위

2026-09-07, Windows의 `codex-cli 0.151.0` 및 당시 공식 문서를 기준으로 정리했습니다. TOML 문법, 필수 역할 필드, 이름 참조, 내부 링크와 개인 경로 누출의 정적 검사를 통과했습니다. 정적 검사 통과는 실제 역할 로딩이나 모델 실행 성공을 보장하지 않습니다. 공개본을 설치한 별도 세션에서의 역할 실행 및 토큰 절감 비교 실험은 아직 수행하지 않았습니다.

설정 문법과 필수 필드는 저장소 루트에서 Python 3.11 이상으로 아래처럼 다시 확인할 수 있습니다. 이 명령은 역할 실행이나 개인정보·문서 검토를 대신하지 않습니다.

```sh
python -c "import pathlib,tomllib; p=pathlib.Path('.'); c=tomllib.loads((p/'config.example.toml').read_text(encoding='utf-8')); assert c['agents']['max_concurrent_threads_per_session']>=10; roles=[tomllib.loads(f.read_text(encoding='utf-8')) for f in (p/'agents').glob('*.toml')]; assert {r['name'] for r in roles}=={'luna_explorer','sol_executor'}; assert all(all(k in r for k in ('name','description','developer_instructions')) for r in roles); print('PASS')"
```

적용 후에는 작은 읽기 전용 작업을 `luna_explorer`에 맡겨 실제 선택된 역할과 반환 형식을 확인하는 것을 권합니다. 관련 예시는 [delegation.md](examples/delegation.md)에 있습니다.

이 저장소는 개인 운영 설정의 공유본이며 OpenAI 공식 프리셋은 아닙니다. 변경 내용은 [CHANGELOG.md](CHANGELOG.md)에 기록합니다.
